class CreateTrips < ActiveRecord::Migration[8.1]
  def change
    create_table :trips do |t|
      t.string :name, null: false
      t.string :destination, null: false
      t.date :departure_date, null: false
      t.date :return_date, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
