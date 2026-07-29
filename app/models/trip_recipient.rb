class TripRecipient < ApplicationRecord
  belongs_to :trip
  belongs_to :recipient

  validates :recipient_id, uniqueness: { scope: :trip_id }
end
