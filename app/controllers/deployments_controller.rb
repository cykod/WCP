class DeploymentsController < ApplicationController


  current_tab "Deployments"

  # GET /deployments
  # GET /deployments.xml
  def index
    @deployments = current_cloud.active_deployment_list

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deployments }
    end
  end

  def cleanup
    current_cloud.cleanup_deployments!
    redirect_to :action => 'index'
  end

  # GET /deployments/1
  # GET /deployments/1.xml
  def show
    @deployment = Deployment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @deployment }
    end
  end

  # GET /deployments/new
  # GET /deployments/new.xml
  def new
    @deployment = Deployment.new
    @blueprints = Blueprint.select_options
    @clouds = current_company.clouds
  end

  # GET /deployments/1/edit
  def edit
    @deployment = Deployment.find(params[:id])
  end

  # POST /deployments
  # POST /deployments.xml
  def create
    @deployment = Deployment.new(params[:deployment])
    @blueprints = Blueprint.select_options
    @clouds = current_company.clouds

    if params[:commit] && @deployment.valid? 
      @deployment = @deployment.cloud.deploy(@deployment)
      if @deployment
       return redirect_to(@deployment, :notice => 'Deployment created and executing') 
      end
    end
    render :action => "new" 
  end

  # PUT /deployments/1
  # PUT /deployments/1.xml
  def update
    @deployment = Deployment.find(params[:id])

    respond_to do |format|
      if @deployment.update_attributes(params[:deployment])
        format.html { redirect_to(@deployment, :notice => 'Deployment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @deployment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /deployments/1
  # DELETE /deployments/1.xml
  def destroy
    @deployment = Deployment.find(params[:id])
    @deployment.destroy

    respond_to do |format|
      format.html { redirect_to(deployments_url) }
      format.xml  { head :ok }
    end
  end
end
