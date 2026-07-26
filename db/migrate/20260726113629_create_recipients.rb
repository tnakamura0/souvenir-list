class CreateRecipients < ActiveRecord::Migration[8.1]
  def change
    create_table :recipients do |t|
      t.string :name, null: false
      t.string :kind, null: false, default: "individual"
      t.integer :people_count, null:false
      t.text :memo
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
