class AddSouvenirNameToTripRecipients < ActiveRecord::Migration[8.1]
  def change
    add_column :trip_recipients, :souvenir_name, :string
  end
end
