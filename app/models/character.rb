class Character
  attr_reader :skills

  def initialize(skills = Skill.all)
    @skills = skills
  end

  def xp
    skills.sum(&:xp)
  end

  def level
    Level.for(xp)
  end
end
