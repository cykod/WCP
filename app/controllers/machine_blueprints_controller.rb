class MachineBlueprintsController < ApplicationController

  current_tab "M. Blueprints"
  


  # GET /machine_blueprints
  # GET /machine_blueprints.xml
  def index
    @machine_blueprints = MachineBlueprint.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @machine_blueprints }
    end
  end

  # GET /machine_blueprints/1
  # GET /machine_blueprints/1.xml
  def show
    @machine_blueprint = MachineBlueprint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @machine_blueprint }
    end
  end

  # GET /machine_blueprints/new
  # GET /machine_blueprints/new.xml
  def new
    @machine_blueprint = MachineBlueprint.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @machine_blueprint }
    end
  end

  # GET /machine_blueprints/1/edit
  def edit
    @machine_blueprint = MachineBlueprint.find(params[:id])
  end

  # POST /machine_blueprints
  # POST /machine_blueprints.xml
  def create
    @machine_blueprint = MachineBlueprint.new(params[:machine_blueprint])

    respond_to do |format|
      if @machine_blueprint.save
        format.html { 
           redirect_to(edit_machine_blueprint_url(@machine_blueprint), :notice => 'Verify Machine Parameters and Hit Submit to save.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /machine_blueprints/1
  # PUT /machine_blueprints/1.xml
  def update
    @machine_blueprint = MachineBlueprint.find(params[:id])

    respond_to do |format|
      if @machine_blueprint.update_attributes(params[:machine_blueprint])
        format.html { redirect_to(machine_blueprints_url, :notice => 'Machine blueprint was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @machine_blueprint.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /machine_blueprints/1
  # DELETE /machine_blueprints/1.xml
  def destroy
    @machine_blueprint = MachineBlueprint.find(params[:id])
    @machine_blueprint.destroy

    respond_to do |format|
      format.html { redirect_to(machine_blueprints_url) }
      format.xml  { head :ok }
    end
  end
end
