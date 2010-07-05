class MachinesController < ApplicationController

  current_tab "Machines"
  
  # GET /machines
  # GET /machines.xml
  def index
    @machines = Machine.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @machines }
    end
  end

  # GET /machines/1
  # GET /machines/1.xml
  def show
    @machine = Machine.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @machine }
    end
  end

  # GET /machines/1/edit
  def edit
    @machine = Machine.find(params[:id])
  end

   # PUT /machines/1
  # PUT /machines/1.xml
  def update
    @machine = Machine.find(params[:id])

    respond_to do |format|
      if @machine.update_attributes(params[:machine])
        format.html { redirect_to(@machine, :notice => 'Machine was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @machine.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /machines/1
  # DELETE /machines/1.xml
  def destroy
    @machine = Machine.find(params[:id])
    @machine.destroy

    respond_to do |format|
      format.html { redirect_to(machines_url) }
      format.xml  { head :ok }
    end
  end
end
