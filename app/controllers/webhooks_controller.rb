class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    signature_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['WEBHOOK_SIGNING_SECRET']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, signature_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      render json: { message: e }, status: 400
    rescue Stripe::SignatureVerificationError => e
      render json: { message: e }, status: 400
      return
    end

    case event.type
    when 'checkout.session.completed'
      
      return if !User.exists?(event.data.object.client_reference_id)
      fullfill_order(event.data.object)

    when 'checkout.session.async_payment_succeeded'
      
    when 'invoice.payment_succeeded'

      return unless event.data.object.subscription.present?

      stripe_subscription = Stripe::Subscription.retrieve(event.data.object.subscription)

      subscription = Subscription.find_by(subscription_id: stripe_subscription)

      subscription.update(
        current_period_start: Time.at(stripe_subscription.current_period_start).to_datetime,
        current_period_end: Time.at(stripe_subscription.current_period_end).to_datetime,
        plan_id: stripe_subscription.plan.id,
        interval: stripe_subscription.interval,
        status: stripe_subscription.status
      )

    when 'invoice.payment_failed'

      user = User.find_by(stripe_id: event.data.object.customer)

      if user.exists?
        SubscriptionMailer.with(user: user).payment_failed.deliver_now
      end

    when 'customer.subscription.updated'
      stripe_subscription = event.data.object
      
      if stripe_subscription.cancel_at_period_end == true
        subscription = Subscription.find_by(subscription_id: stripe_subscription.id)

        if subscription.present?
          subscription.update(
            current_period_start: Time.at(stripe_subscription.current_period_start).to_datetime,
            current_period_end: Time.at(stripe_subscription.current_period_end).to_datetime,
            plan_id: stripe_subscription.plan.id,
            interval: stripe_subscription.interval,
            status: stripe_subscription.status
          )
        end
      end

    else
      puts "Unhandled event type : #{event.type}"
    end

    render json: { message: 'success' }

  end

  private

  def fullfill_order(checkout_session)

    user = User.find(checkout_session.client_reference_id)
    user.update(stripe_id: checkout_session.customer)
    stripe_subscription = Stripe::Subscription.retrieve(checkout_session.subscription)
    Subscription.create(customer_id: stripe_subscription.customer, current_period_start: Time.at(stripe_subscription.current_period_start).to_datetime, current_period_end: Time.at(stripe_subscription.current_period_end).to_datetime, plan_id: stripe_subscription.plan.id, interval: stripe_subscription.plan.interval, status: stripe_subscription.status, subscription_id: stripe_subscription.id, user: user)
    
  end

end
