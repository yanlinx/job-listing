class JobsController < ApplicationController
  before_filter :authenticate_user! ,only: [:new,:create,:edit,:destroy]
  before_filter :validate_search_key , :only => [:search]

  def index
    @jobs = case params[:order]
    when "by_lower_bound"
      Job.published.order("wage_lower_bound DESC").paginate(:page => params[:page], :per_page => 7)
    when "by_upper_bound"
      Job.published.order("wage_upper_bound DESC").paginate(:page => params[:page], :per_page => 7)
    else
      Job.published.recent.paginate(:page => params[:page], :per_page => 7)
    end
  end

  def new
    @job = Job.new
  end
  def show
    @job = Job.find(params[:id])
    if @job.is_hidden
    flash[:warning] = "This job already archieved"
    redirect_to jobs_path
  end
end

  def edit
    @job = Job.find(params[:id])
  end

  def create
    @job = Job.new(job_params)
    if @job.save
    redirect_to jobs_path
  else
    render :new
  end
end
  def update
    @job = Job.find(params[:id])
    if @Job.update(job_params)
      redirect_to jobs_path
    else
      render :edit
    end
  end

  def destroy
    @job = Job.find(params[:id])
    if @job.destroy
      redirect_to jobs_path,alert: "Job delete"
 end
 end

 def search
     if @query_string.present?
       search_result = Job.ransack(@search_criteria).result(:distinct => true)
       @jobs = search_result.paginate(:page => params[:page], :per_page => 10)
       puts @jobs
     else
       @jobs = Job.published.recent.paginate(:page => params[:page], :per_page => 10)
       puts @jobs
     end
   end

private
def validate_search_key
    @query_string = params[:q].gsub(/\\|\'|\/|\?/, "") if params[:q].present?
    @search_criteria = search_criteria(@query_string)
end

def search_criteria(query_string)
    { :title_or_location_or_contact_email_cont => query_string }
end


def job_params
  params.require(:job).permit(:title,:description,:wage_upper_bound,:wage_lower_bound,:contact_email,:is_hidden,:location,:company_name)
end

end
