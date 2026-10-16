class Challenge < ApplicationRecord
  belongs_to :group
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

  private
    def slipped_dates
      @slipped_dates ||= slips.pluck(:day).to_set
    end
end
