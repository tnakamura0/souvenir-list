class Recipient < ApplicationRecord
  belongs_to :user

  enum :kind,
      {
        individual: "individual",
        group: "group"
      },
      prefix: true,
      validate: {
        presence: true
      }

  validates :name, presence: true
  validates :people_count, presence: true
end
