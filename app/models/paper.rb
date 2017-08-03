class Paper < ApplicationRecord
  has_many :enrolls
  has_many :users, through: :enrolls
  has_many :assigns
  has_many :problems, through: :assigns
  attr_accessor :problems_list
  attr_accessor :orgs_list
  accepts_nested_attributes_for :problems

  validates :code, uniqueness: true
  validates :deadline, :title, presence: true
  validates_each :deadline do |record, attr, value|
    if value < Time.now
      record.errors.add attr, "截止日期必须晚于当前时间"
    end
  end

  before_validation :generate_code
  after_save :add_problems

  default_scope { where(trashed: false) }

  def trash
    update_column :trashed, true
  end

  def terminate
    update_column :deadline, Time.now
  end

  def rank_for(score)
    Paper.count_by_sql("select array_position((select ARRAY(select score from enrolls where paper_id='#{self.id}' order by score desc nulls last)), '#{score}')")
  end

  def repush
    paper = dup

    total_score = assigns.sum(:problem_score)
    failed_user_ids = enrolls.where('score < ?', total_score * 0.6).pluck(:user_id)
    paper.user_ids = failed_user_ids

    paper.save

    assigns_params = assigns.map do |assign|
      assign.attributes.slice("problem_id", "problem_score").merge("paper_id" => paper.id)
    end

    Assign.import assigns_params

    #PublishPaperJob.perform_later paper
  end

  def self.search(q)
    Paper.where('title like ?', "%#{q}%")
  end

  private

  def generate_code
    begin
      self.code = SecureRandom.urlsafe_base64
    end while self.class.exists?(code: self.code)
  end

  def add_problems
    unless problems_list.nil?
      assigns_params = []

      problems_list.split(';').each do |id_score|
        problem_id, score = id_score.split('-')
        assigns_params.push paper_id: self.id, problem_id: problem_id, problem_score: score
      end

      Assign.import assigns_params
    end
  end
end
