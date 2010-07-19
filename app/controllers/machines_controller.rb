class MachinesController < ApplicationController

  current_tab "Machines"
  
  # GET /machines
  # GET /machines.xml
  def index
    @machines = current_cloud.machines

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @machines }
    end
  end

  def cleanup
    machines_to_cleanup = current_cloud.machines.select { |machine| machine.terminated? }
    machines_to_cleanup.map { |m| m.destroy }
    redirect_to :action => 'index'
  end

  # GET /machines/1
  # GET /machines/1.xml
  def show
    @machine = current_cloud.cloud_machine(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @machine }
    end
  end

  # GET /machines/1/edit
  def edit
    @machine = Machine.find(params[:id])
  end

  def destroy
    @machine = Machine.find(params[:id])
    @machine.terminate!

    redirect_to :action => 'index'
  end

   # PUT /machines/1
  # PUT /machines/1.xml
  def update
    @machine = Machine.find(params[:id])

    @machine.attributes = params[:machine]
    respond_to do |format|
      if @machine.valid? && @machine.save
        format.html { redirect_to(@machine, :notice => 'Machine was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @machine.errors, :status => :unprocessable_entity }
      end
    end
  end
end
