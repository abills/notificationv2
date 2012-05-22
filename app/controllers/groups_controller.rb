class GroupsController < ApplicationController
  before_filter :check_for_cancel, :only => [:create, :update]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        format.html { redirect_to groups_url, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.json
  def update
    @group = Group.find(params[:id])

    begin
      @group.users.find(current_user.id)
      @group.users.delete(current_user)

      respond_to do |format|
        if @group.update_attributes(params[:group])
          format.html { redirect_to groups_url, notice: 'Group was successfully removed.' }
          format.json { head :no_content }
        else
          format.html { redirect_to groups_url, notice: 'Error removing Group' }
          format.json { head :no_content }
        end
      end
    rescue
      @group.users.push(current_user)

      respond_to do |format|
        if @group.update_attributes(params[:group])
          format.html { redirect_to groups_url, notice: 'Group was successfully added.' }
          format.json { head :no_content }
        else
          format.html { redirect_to groups_url, notice: 'Error adding Group' }
          format.json { head :no_content }
        end
      end
    end


  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :no_content }
    end
  end

  private
    def check_for_cancel
      unless params[:cancel].blank?
        redirect_to groups_url, :notice => "Changes discarded"
      end
    end
end
