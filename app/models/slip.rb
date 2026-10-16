class Slip < ApplicationRecord
  belongs_to :challenge

  delegate :project, to: :challenge

  validates :day, presence: true, uniqueness: { scope: :challenge_id }
  validate :day_within_project, :day_not_in_future, if: -> { day && challenge }

  private
    def day_within_project
      errors.add :day, "fora dos 75 dias do projeto" unless project.days.cover?(day)
    end

    def day_not_in_future
      errors.add :day, "não pode ser no futuro" if day > Date.current
    end
end
