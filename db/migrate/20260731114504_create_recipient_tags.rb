class CreateRecipientTags < ActiveRecord::Migration[8.1]
  def change
    create_table :recipient_tags do |t|
      t.references :recipient, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps

      t.index [ :recipient_id, :tag_id ], unique: true
    end
  end
end
