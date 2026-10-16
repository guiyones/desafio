class Challenge < ApplicationRecord
  XP_PER_DAY = 10

  belongs_to :group
  belongs_to :skill, optional: true
  has_many :slips, dependent: :destroy

  delegate :project, to: :group

  validates :name, presence: true

  def status_on(date)
    if date > Date.current
      :future
    elsif slipped_dates.include?(date)
      :slipped
    else
      :kept
    end
  end

  def slips_count
    slips.size
  end

  def kept_count
    project.elapsed_days.count - slips_count
  end

  def kept_percentage
    elapsed = project.elapsed_days.count
    elapsed.zero? ? 0 : (kept_count * 100.0 / elapsed).round
  end

  def xp
    kept_count * XP_PER_DAY
  end

  private
    def slipped_dates
      slips.map(&:day).to_set
    end
end
