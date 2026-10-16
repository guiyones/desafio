module Project::Results
  extend ActiveSupport::Concern

  def slips_count
    slips.count
  end

  def perfect_days
    return [] if challenges.none?

    slipped = slips.pluck(:day).to_set
    elapsed_days.reject { |day| slipped.include?(day) }
  end

  def slips_timeline
    slips.includes(:challenge).reorder(:day, :id)
  end
end
