class Admin::PapersController < Admin::ApplicationController
  before_action :find_paper, only: [:show, :duplicate, :destroy, :terminate, :ranking, :repush]
  before_action only: [:index, :show, :search] { set_nav(:past_papers, true) }
  before_action only: [:dash, :new, :duplicate] { set_nav(:new_paper, true) }

  def dash
    @problems = Problem.untrashed.includes(:options, :tags).order(id: :desc).page(params[:page])
  end

  def index
    @papers = Paper.order(id: :desc).page(params[:page]).per(9)

    if params[:scale]
      if params[:scale] == '1'
        @papers = @papers.where(scale: 1)
      else
        @papers = @papers.where(scale: 2)
      end
    elsif params[:status]
      if params[:status] == '0'
        @papers = @papers.where('deadline > ?', Time.now)
      else
        @papers = @papers.where('deadline < ?', Time.now)
      end
    end
  end

  def show
    @problems = Problem.includes(:options, :tags).with_score(@paper.id)
  end

  def new
    @paper = Paper.new

    if params[:method] == 'random'
      single_problems = Problem.untrashed.single.includes(:options, :tags).order('random()').limit(params[:single].to_i)
      multi_problems = Problem.untrashed.multi.includes(:options, :tags).order('random()').limit(params[:multi].to_i)
      problems_by_tags = Problem.includes(:options, :tags).random_by_tags(params[:tags_list])
      @problems = single_problems + multi_problems + problems_by_tags
      render 'randomly_new'
    elsif params[:method] == 'manually'
      @problems, @remote = filter_problems
      if @remote
        render 'manually_new', layout: false
      else
        render 'manually_new'
      end
    end
  end

  def create
    @paper = Paper.new(paper_params.merge(deadline: Time.parse(paper_params[:deadline])))
    if @paper.save
      PublishPaperJob.perform_later @paper, paper_params[:orgs_list]
      redirect_to admin_paper_url @paper
    else
      render body: nil
    end
  end

  def duplicate
    @problems = Problem.includes(:options, :tags).with_score(@paper.id)
    @paper = @paper.dup
    render 'randomly_new'
  end

  def repush
    @paper.repush
  end

  def terminate
    @paper.terminate
    redirect_to admin_paper_url(@paper)
  end

  def destroy
    @paper.trash
    redirect_to admin_papers_url
  end

  def search
    @papers = Paper.search(params[:q].to_s).order(id: :desc).page(params[:page]).per(9)
    respond_to do |format|
      format.html { render :index }
      format.json do
        @papers = @papers.page(1).per(5)
        render json: @papers.to_json(only: :title)
      end
    end
  end

  def ranking
    PushRankJob.perform_later @paper
  end

  def orgs
    @orgs = SkylarkAdapter.get_orgs

    respond_to do |format|
      format.json do
        render json: @orgs.to_json(only: [:id, :name])
      end
    end
  end

  private

  def paper_params
    params.require(:paper).permit(:title, :scale, :problems_list, :deadline, :orgs_list)
  end

  def find_paper
    @paper = Paper.find(params[:id])
  end
end
