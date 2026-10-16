class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]

  def index
    @projects = Project.order(:starts_on)
    redirect_to @projects.first if @projects.one?
  end

  def show
  end

  def new
    @project = Project.new(starts_on: Date.current)
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, status: :see_other
  end

  private
    def set_project
      @project = Project.find(params[:id])
    end

    def project_params
      params.expect(project: [ :name, :starts_on ])
    end
end
