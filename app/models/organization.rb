class Organization < ApplicationRecord
  has_ancestry

  has_and_belongs_to_many :users
  has_many :employees, class_name: 'User', foreign_key: 'company_id'

  validates :uid, presence: true, uniqueness: true
  validates :name, presence: true

  scope :root, -> { where(ancestry: nil) }
  scope :leaf, -> { where(children_count: 0) }

  def self.order_by_score_for(period)
    start_time, end_time = case period
                           when :month
                             [Time.now.at_beginning_of_month, Time.now.at_end_of_month]
                           when :quarter
                             [Time.now.at_beginning_of_quarter, Time.now.at_end_of_quarter]
                           end

    Organization.joins(users: [:enrolls]).group('organizations.id')
      .order("SUM(CASE WHEN enrolls.created_at > '#{start_time.to_s(:db)}' AND enrolls.created_at < '#{end_time.to_s(:db)}' THEN enrolls.score ELSE 0 END) DESC NULLS LAST")
  end
end
