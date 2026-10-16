class Project < ApplicationRecord
  include Results

  DURATION = 75

  has_many :groups, dependent: :destroy
  has_many :challenges, through: :groups
  has_many :slips, through: :challenges

  validates :name, :starts_on, presence: true
  validate :starts_on_locked, on: :update

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

  private
    def starts_on_locked
      errors.add :starts_on, "não pode mudar depois de marcar vacilos" if starts_on_changed? && slips.exists?
    end
end
