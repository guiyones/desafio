class GroupsController < ApplicationController
  before_action :set_project, only: %i[ new create ]
  before_action :set_group, only: %i[ edit update destroy ]

  def new
    @group = @project.groups.new
  end

  def create
    @group = @project.groups.new(group_params)

    if @group.save
      redirect_to @project
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @group.update(group_params)
      redirect_to @group.project
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @group.destroy
    redirect_to @group.project, status: :see_other
  end

  private
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_group
      @group = Group.find(params[:id])
    end

    def group_params
      params.expect(group: [ :name ])
    end
end
