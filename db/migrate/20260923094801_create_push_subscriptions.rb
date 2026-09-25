class CreatePushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :push_subscriptions do |t|
      t.text :endpoint, null: false
      t.string :p256dh, null: false
      t.string :auth, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps

      # endpointはSubscriptionを識別するURLなので重複を防ぐ
      t.index :endpoint, unique: true
    end
  end
end
