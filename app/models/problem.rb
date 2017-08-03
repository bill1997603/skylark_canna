class Problem < ApplicationRecord
  has_many :options, -> { order(id: :asc) }, dependent: :destroy
  has_and_belongs_to_many :papers
  has_and_belongs_to_many :tags
  has_many :assigns
  has_many :papers, through: :assigns
  attr_accessor :tags_list

  validates :description, presence: true
  validates :form, inclusion: { in: [1, 2, 3] }
  validates :options, length: { minimum: 2 }
  validates_each :options do |record, attr, value|
    unless value.detect { |option| option.right }
      record.errors.add attr, "至少选择一个正确答案"
    end
  end

  accepts_nested_attributes_for :options, allow_destroy: true

  before_save :create_or_add_tags

  scope :untrashed, -> { where(trashed: false) }
  scope :single, -> { where(form: 1) }
  scope :multi, -> { where(form: 2) }

  def self.with_score(paper_id)
    joins(:assigns).where(assigns: { paper_id: paper_id }).select("problems.*, assigns.problem_score as score")
  end

  def self.random_by_tags(tags_list)
    problems = []
    tag_descriptions = []
    tag_amounts = []

    tags_list.split(';').each do |description_amount|
      tag_description, tag_amount = description_amount.split('-')
      tag_descriptions.push tag_description
      tag_amounts.push tag_amount
    end

    tag_descriptions.each_with_index do |tag_description, i|
      problems.concat(
        Problem.untrashed.joins(:tags).where(tags: { description: tag_description }).where.not(tags: { description: (tag_descriptions - [tag_description]) })
               .order('random()').limit(tag_amounts[i]))
    end

    problems
  end

  def trash
    update_column :trashed, true
  end

  def update_with_papers(problem_params)
    new_problem = self.dup
    origin_options = options
    origin_tags = tags

    new_problem.trashed = true
    origin_options.each { |option| new_problem.options << option.dup }
    new_problem.tags = origin_tags

    unless update(problem_params)
      false
    else
      new_problem.save

      assigns.each do |assign|
        assign.update(problem_id: new_problem.id)
      end
      true
    end
  end

  def self.import(filename)
    file = Roo::Spreadsheet.open(filename)
    file.each do |row|
      form, description, text_options, right_optin_labels, tags = row
      next if description.nil? || text_options.nil?

      problem_attributes = {
        description: description,
        form: form == '单选' ? 1 : 2,
        tags_list: tags,
        options_attributes: []
      }

      text_options = text_options.split(';')
      right_optin_labels = right_optin_labels.split(';').map(&:upcase)

      text_options.each_with_index do |option_description, index|
        problem_attributes[:options_attributes] << {
          description: option_description,
          right: right_optin_labels.include?((index + 65).chr)
        }
      end

      Problem.create(problem_attributes)
    end
  end

  def self.search(q)
    Problem.where('description like ?', "%#{q}%")
  end

  def right?(chosen_list)
    return false if chosen_list.blank?

    chosen_list_array = chosen_list.split(';').collect { |id| id.to_i }

    options.where(right: true).each do |right_option|
      unless chosen_list_array.include? right_option.id
        return false
      end
    end

    return true
  end

  private

  def create_or_add_tags
    unless tags_list.nil?
      self.tags = []
      tags_list.split(';').each do |description|
        tag = Tag.find_or_create_by(description: description)
        if tag.id.nil?
          errors.add(:tags, "标签值错误")
          throw :abort
        else
          tags << tag
        end
      end
    end
  end
end
