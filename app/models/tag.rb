class Tag < ApplicationRecord
  belongs_to :user

  has_many :recipient_tags, dependent: :destroy
  has_many :recipients, through: :recipient_tags

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
