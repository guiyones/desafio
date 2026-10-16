class Challenges::SlipsController < ApplicationController
  before_action :set_challenge
  before_action :set_slip, only: %i[ edit update destroy ]

  def create
    @slip = @challenge.slips.new(day: params[:day])

    if @slip.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @challenge.project }
      end
    else
      head :unprocessable_content
    end
  end

  def edit
  end

  def update
    @slip.update!(slip_params)
    redirect_to @challenge.project
  end

  def destroy
    @slip.destroy
    redirect_to @challenge.project, status: :see_other
  end

  private
    def set_challenge
      @challenge = Challenge.find(params[:challenge_id])
    end

    def set_slip
      @slip = @challenge.slips.find_by!(day: params[:day])
    end

    def slip_params
      params.expect(slip: [ :note ])
    end
end
