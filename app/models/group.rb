class Group < ApplicationRecord
  belongs_to :project
  has_many :challenges, dependent: :destroy
  has_many :slips, through: :challenges

  validates :name, presence: true

  def slips_count
    slips.count
  end
end
