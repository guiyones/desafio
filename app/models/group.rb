class Group < ApplicationRecord
  belongs_to :project
  has_many :challenges, dependent: :destroy

  validates :name, presence: true
end
