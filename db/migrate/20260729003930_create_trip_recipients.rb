class CreateTripRecipients < ActiveRecord::Migration[8.1]
  def change
    create_table :trip_recipients do |t|
      t.references :trip, null: false, foreign_key: true
      t.references :recipient, null: false, foreign_key: true
      t.boolean :purchased, null: false, default: false

      t.timestamps

      t.index [ :trip_id, :recipient_id ], unique: true
    end
  end
end
