class Trip < ApplicationRecord
  belongs_to :user

  has_many :trip_recipients, dependent: :destroy
  has_many :recipients, through: :trip_recipients

  validates :name, presence: true
  validates :destination, presence: true
  validates :departure_date, presence: true
  validates :return_date, presence: true, comparison: { greater_than_or_equal_to: :departure_date }
end
