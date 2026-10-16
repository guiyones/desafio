class AddSkillToChallenges < ActiveRecord::Migration[8.1]
  def change
    add_reference :challenges, :skill, null: true, foreign_key: true
  end
end
