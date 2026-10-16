class ChallengesController < ApplicationController
  before_action :set_group, only: %i[ new create ]
  before_action :set_challenge, only: %i[ edit update destroy ]

  def new
    @challenge = @group.challenges.new
  end

  def create
    @challenge = @group.challenges.new(challenge_params)

    if @challenge.save
      redirect_to @challenge.project
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @challenge.update(challenge_params)
      redirect_to @challenge.project
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @challenge.destroy
    redirect_to @challenge.project, status: :see_other
  end

  private
    def set_group
      @group = Group.find(params[:group_id])
    end

    def set_challenge
      @challenge = Challenge.find(params[:id])
    end

    def challenge_params
      params.expect(challenge: [ :name, :skill_id ])
    end
end
