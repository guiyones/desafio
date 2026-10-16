class Skill < ApplicationRecord
  has_many :challenges, dependent: :nullify

  validates :name, :icon, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  def xp
    challenges.sum(&:xp)
  end

  def level
    Level.for(xp)
  end

  def active_challenges_count
    challenges.count { it.project.status == :active }
  end
end
