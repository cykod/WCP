class CompanyController < ApplicationController

  current_tab "Company"

  def index
    @company = myself.company
  end

  def update
    return redirect_to company_url unless params[:company]
    @company = myself.company
    @company.attributes = params[:company].slice(:name, :aws_key, :aws_secret, :key_name)

    if @company.valid? && @company.save
      flash[:notice] = "Company information updated"
      return redirect_to company_url
    end

    render :action => 'index'
  end

end
