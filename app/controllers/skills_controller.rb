class SkillsController < ApplicationController
  before_action :set_skill, only: %i[ edit update destroy ]

  def index
    @character = Character.new(Skill.order(:name).includes(challenges: [ :slips, { group: :project } ]))
  end

  def new
    @skill = Skill.new
  end

  def create
    @skill = Skill.new(skill_params)

    if @skill.save
      redirect_to skills_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @skill.update(skill_params)
      redirect_to skills_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @skill.destroy
    redirect_to skills_path, status: :see_other
  end

  private
    def set_skill
      @skill = Skill.find(params[:id])
    end

    def skill_params
      params.expect(skill: [ :name, :icon ])
    end
end
