class Projects::ResultsController < ApplicationController
  def show
    @project = Project.find(params[:project_id])
    @groups = @project.groups.order(:id).includes(challenges: [ :slips, :skill ])
  end
end
