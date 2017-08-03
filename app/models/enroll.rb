class Enroll < ApplicationRecord
  belongs_to :user
  belongs_to :paper

  scope :finished, -> { where.not(hand_in_time: nil) }
  scope :unfinished, -> { where(hand_in_time: nil) }

  scope :current_week,
    -> { where('created_at > ? AND created_at < ?',
               Time.now.at_beginning_of_week, Time.now.at_end_of_week) }
  scope :current_month,
    -> { where('created_at > ? AND created_at < ?',
               Time.now.at_beginning_of_month, Time.now.at_end_of_month) }
  scope :current_quarter,
    -> { where('created_at > ? AND created_at < ?',
               Time.now.at_beginning_of_quarter, Time.now.at_end_of_quarter) }

  def self.search(name)
    Enroll.joins(:user).where('users.name like ?', "%#{name}%")
  end
end
