class Admin::ProblemsController < Admin::ApplicationController
  before_action :find_problem, only: [:show, :edit, :update, :destroy]
  before_action { set_nav(:problems, true) }

  def index
    @problems, @remote = filter_problems

    if @remote
      render layout: false
    end

    @page_title = '题库'
  end

  def new
    @problem = Problem.new
    4.times { @problem.options.build }
    render layout: false
  end

  def show
    render layout: false
  end

  def create
    @problem = Problem.create(problem_params)
    puts @problem.errors.messages
    respond_to do |format|
      format.js
    end
  end

  def edit
    render layout: false
  end

  def update
    @problem.update_with_papers problem_params
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @problem.trash
    redirect_to admin_problems_path
  end

  def template
    send_file Rails.root + 'public/admin/problems/template.csv'
  end

  def upload
    uploaded_io = params[:file]
    filename = Rails.root.join('public', "#{Time.now.to_i}-#{uploaded_io.original_filename}")
    FileUtils.cp(uploaded_io.tempfile.path, filename)
    ProblemProcessorJob.perform_later filename.to_s
    redirect_to admin_problems_path
  end

  def search
    @problems = Problem.includes(:options, :tags).search(params[:q].to_s).order(id: :desc).page(params[:page])
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @problems.per(5).to_json(only: :description) }
    end
  end

  private

  def problem_params
    params.require(:problem).permit(:description, :form, :tags_list,
                                   options_attributes: [:id, :description, :right, :_destroy])
  end

  def find_problem
    @problem = Problem.find(params[:id])
  end
end
