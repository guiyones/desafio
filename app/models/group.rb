class Group < ApplicationRecord
  belongs_to :project
  has_many :challenges, -> { order(:id) }, dependent: :destroy
  has_many :slips, through: :challenges

  validates :name, presence: true

  def slips_count
    challenges.sum(&:slips_count)
  end
end
