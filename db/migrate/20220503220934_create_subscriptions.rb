class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.string :plan_id
      t.string :customer_id
      t.references :user, null: false, foreign_key: true
      t.string :status
      t.datetime :current_period_start
      t.datetime :current_periode_end

      t.timestamps
    end
  end
end
