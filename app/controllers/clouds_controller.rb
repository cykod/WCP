class CloudsController < ApplicationController
  current_tab "Clouds"

  before_filter :ensure_current_company

  # GET /clouds
  # GET /clouds.xml
  def index
    @clouds = current_company.clouds

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @clouds }
    end
  end

  # GET /clouds/1
  # GET /clouds/1.xml
  def show
    @cloud = current_company.company_cloud(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cloud }
    end
  end

  def reset
    @cloud = current_company.company_cloud(params[:cloud_id])

    @cloud.force_reset
    redirect_to @cloud
  end

  # GET /clouds/new
  # GET /clouds/new.xml
  def new
    @cloud = Cloud.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cloud }
    end
  end

  # GET /clouds/1/edit
  def edit
    @cloud = current_company.company_cloud(params[:id])
  end

  # POST /clouds
  # POST /clouds.xml
  def create
    @cloud = Cloud.new(params[:cloud].merge({:company_id => current_company.id}))

    respond_to do |format|
      if @cloud.valid? &&  @cloud.save
        @cloud.save_cloud_databag
        format.html { redirect_to(@cloud, :notice => 'Cloud was successfully created.') }
        format.xml  { render :xml => @cloud, :status => :created, :location => @cloud }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cloud.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /clouds/1
  # PUT /clouds/1.xml
  def update
    @cloud = current_company.company_cloud(params[:id])
    @cloud.attributes = params[:cloud]

    respond_to do |format|
      if @cloud.valid? && @cloud.save
        @cloud.save_cloud_databag
        format.html { redirect_to(@cloud, :notice => 'Cloud was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cloud.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /clouds/1
  # DELETE /clouds/1.xml
  def destroy
    @cloud = current_company.company_cloud(params[:id])
    @cloud.destroy

    flash[:notice] = "Destroyed cloud"

    respond_to do |format|
      format.html { redirect_to(clouds_url) }
      format.xml  { head :ok }
    end
  end

end
