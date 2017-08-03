class Users::PapersController < Users::ApplicationController
  layout 'users'

  before_action :filter_papers, only: [:index]
  before_action :find_paper, only: [:show, :detail, :ranking]
  before_action :find_paper_by_code, only: [:new, :create]
  before_action :detect_paper_availability, only: [:new, :create]

  def new
    if !@available && current_user.paper_ids.include?(@paper.id)
      redirect_to users_paper_url(@paper)
    end

    @assigns = Assign.includes(problem: [:options]).joins(:paper).where(paper: @paper)
  end

  def organizations
  end

  def create
    if @available
      current_user.hand_in(@paper, paper_params[:assigns_attributes])
      redirect_to users_paper_url(@paper)
    else
      render :hand_in_error
    end
  end

  def index
  end

  def show
    @enroll = current_user.enrolls.find_by!(paper: @paper)
    @rank = @paper.rank_for(@enroll.score) unless @enroll.hand_in_time.nil?
  end

  def detail
    @available = false
    @detailed = true
    @enroll = current_user.enrolls.finished.find_by!(paper: params[:id])
    @assigns = Assign.includes(problem: [:options]).joins(:paper).where(paper: @paper)
    render :new
  end

  def ranking
    @enrolls = @paper.enrolls.order('score DESC NULLS LAST')
  end

  def search
    @papers = current_user.papers.search(params[:q].to_s).distinct.order(created_at: :desc)
    render :index
  end

  private

  def filter_papers
    @papers = current_user.papers.distinct.order(created_at: :desc)

    if params[:scale]
      @papers = @papers.where(scale: params[:scale])
    elsif params[:running]
      if params[:running] == '0'
        @papers = @papers.where('deadline < ?', Time.now)
      else
        @papers = @papers.where('deadline > ?', Time.now)
      end
    elsif params[:finished]
      if params[:finished] == '0'
        @papers = @papers.joins(:enrolls).where(enrolls: { hand_in_time: nil })
      else
        @papers = @papers.joins(:enrolls).where.not(enrolls: { hand_in_time: nil })
      end
    end
  end

  def detect_paper_availability
    @available = false
    enroll = current_user.enrolls.find_by(paper: @paper)

    if enroll
      unless enroll.hand_in_time
        if Time.now < @paper.deadline
          @available = true
        end
      end
    end
  end

  def find_paper
    @paper = current_user.papers.find(params[:id])
  end

  def find_paper_by_code
    @paper = Paper.find_by!(code: params[:code])
  end

  def paper_params
    params.require(:paper).permit(assigns_attributes: [:chosen])
  end
end
