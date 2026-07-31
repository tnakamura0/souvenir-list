class Trip < ApplicationRecord
  belongs_to :user

  has_many :trip_recipients, dependent: :destroy
  has_many :recipients, through: :trip_recipients

  validates :name, presence: true
  validates :destination, presence: true
  validates :departure_date, presence: true
  validates :return_date, presence: true, comparison: { greater_than_or_equal_to: :departure_date }

  def total_count
    trip_recipients.count
  end

  def purchased_count
    trip_recipients.where(purchased: true).count
  end

  def progress_percentage
    total = total_count
    return 0 if total.zero?

    (purchased_count.to_f / total * 100).round
  end
end
