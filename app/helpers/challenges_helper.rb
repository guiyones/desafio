module ChallengesHelper
  def day_dom_id(challenge, date)
    dom_id(challenge, "day_#{date.iso8601}")
  end
end
