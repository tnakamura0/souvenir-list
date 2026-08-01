class RecipientTag < ApplicationRecord
  belongs_to :recipient
  belongs_to :tag

  validates :recipient_id, uniqueness: { scope: :tag_id }
end
