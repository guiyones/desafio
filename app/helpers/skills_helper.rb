module SkillsHelper
  def level_up_banner(skills)
    render "shared/level_up", skills: skills
  end
end
