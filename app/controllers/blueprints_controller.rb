class BlueprintsController < ApplicationController

  current_tab 'Blueprints'

  # GET /blueprints
  # GET /blueprints.xml
  def index
    @blueprints = Blueprint.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @blueprints }
    end
  end

  # GET /blueprints/1
  # GET /blueprints/1.xml
  def show
    @blueprint = Blueprint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blueprint }
    end
  end

  # GET /blueprints/new
  # GET /blueprints/new.xml
  def new
    @blueprint = Blueprint.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @blueprint }
    end
  end


  def add_step
    @blueprint = Blueprint.find(params[:id])

    if full_class = BlueprintStep.check_step_identifier(params[:step_class])
      @blueprint.add_step(params[:name],full_class)
    end

    @blueprint.reload
    
    render :partial => 'blueprint_steps'
  end


  def resort_steps
    @blueprint = Blueprint.find(params[:id])

    @steps = @blueprint.blueprint_steps

    (params['step_id']||[]).each_with_index do |step_id,position|
       step = @steps.detect { |s| s.id == step_id} 
       step.update_attributes(:position => position+1) if step
    end

    @blueprint.reload
     
    render :partial => 'blueprint_steps'
  end


  def delete_step
    @step = BlueprintStep.find(params[:step_id])
    @step.destroy

    @blueprint = Blueprint.find(params[:id])
    @blueprint.resort_steps!

    render :partial => 'blueprint_steps'
  end

  # GET /blueprints/1/edit
  def edit
    @blueprint = Blueprint.find(params[:id])
  end

  # POST /blueprints
  # POST /blueprints.xml
  def create
    @blueprint = Blueprint.new(params[:blueprint])

    respond_to do |format|
      if @blueprint.save
        format.html { redirect_to(@blueprint, :notice => 'Blueprint was successfully created.') }
        format.xml  { render :xml => @blueprint, :status => :created, :location => @blueprint }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @blueprint.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /blueprints/1
  # PUT /blueprints/1.xml
  def update
    @blueprint = Blueprint.find(params[:id])

    respond_to do |format|
      if @blueprint.update_attributes(params[:blueprint])
        format.html { redirect_to(blueprint_path(@blueprint), :notice => 'Blueprint was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blueprint.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /blueprints/1
  # DELETE /blueprints/1.xml
  def destroy
    @blueprint = Blueprint.find(params[:id])
    @blueprint.destroy

    respond_to do |format|
      format.html { redirect_to(blueprints_url) }
      format.xml  { head :ok }
    end
  end
end
