class Project < ApplicationRecord
  DURATION = 75

  has_many :groups, dependent: :destroy
  has_many :challenges, through: :groups
  has_many :slips, through: :challenges

  validates :name, :starts_on, presence: true

  def ends_on
    starts_on + (DURATION - 1)
  end

  def days
    starts_on..ends_on
  end

  def day_number(date)
    (date - starts_on).to_i + 1
  end

  def status
    if Date.current < starts_on
      :upcoming
    elsif Date.current > ends_on
      :finished
    else
      :active
    end
  end

  def elapsed_days
    starts_on..[ Date.current, ends_on ].min
  end
end
