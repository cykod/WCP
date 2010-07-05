class DeploymentsController < ApplicationController


  current_tab "Deployments"

  # GET /deployments
  # GET /deployments.xml
  def index
    @deployments = Deployment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deployments }
    end
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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @deployment }
    end
  end

  # GET /deployments/1/edit
  def edit
    @deployment = Deployment.find(params[:id])
  end

  # POST /deployments
  # POST /deployments.xml
  def create
    @deployment = Deployment.new(params[:deployment])

    respond_to do |format|
      if @deployment.save
        format.html { redirect_to(@deployment, :notice => 'Deployment was successfully created.') }
        format.xml  { render :xml => @deployment, :status => :created, :location => @deployment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @deployment.errors, :status => :unprocessable_entity }
      end
    end
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
