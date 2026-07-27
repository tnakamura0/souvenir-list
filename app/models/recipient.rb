class Recipient < ApplicationRecord
  belongs_to :user

  before_validation :set_people_count_for_individual

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

  def display_name
    kind_group? ? "#{name}（#{people_count}人）" : name
  end

  private

  def set_people_count_for_individual
    self.people_count = 1 if kind_individual?
  end
end
