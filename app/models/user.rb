class User < ApplicationRecord
  has_many :enrolls, dependent: :destroy
  has_many :papers, through: :enrolls
  has_and_belongs_to_many :organizations
  belongs_to :company, class_name: 'Organization', optional: true

  validates :uid, presence: true, uniqueness: true
  validates :name, presence: true

  def self.order_by_score_for(period)
    start_time, end_time = case period
                           when :week
                             [Time.now.at_beginning_of_week, Time.now.at_end_of_week]
                           when :month
                             [Time.now.at_beginning_of_month, Time.now.at_end_of_month]
                           when :quarter
                             [Time.now.at_beginning_of_quarter, Time.now.at_end_of_quarter]
                           end

    User.joins(:enrolls).group('users.id')
      .order("SUM(CASE WHEN enrolls.created_at > '#{start_time.to_s(:db)}' AND enrolls.created_at < '#{end_time.to_s(:db)}' THEN enrolls.score ELSE 0 END) DESC NULLS LAST")
  end

  def remember_token
    [id, Digest::SHA512.hexdigest(uid)].join('$')
  end

  def self.find_by_remember_token(token)
    user = find_by_id(token.split('$').first)
    (user && Rack::Utils.secure_compare(user.remember_token, token)) ? user : nil
  end

  def admin?
    CONFIG['admin_accounts']&.include?(uid)
  end

  def self.find_and_auth_admin(uid, password)
    if CONFIG['admin_accounts'][uid]&.fetch('password', nil) == password
      user = User.where(uid: uid).first

      if user
        user
      else
        User.create(uid: uid, name: uid, admin: true)
      end
    else
      nil
    end
  end

  def self.from_omniauth(auth_hash)
    find_or_create_by(uid: auth_hash[:uid]) do |user|
      user.name = auth_hash[:info][:name]
      user.openid = auth_hash[:info][:openid]
    end
  end

  def hand_in(paper, assigs_attributes)
    enroll = enrolls.find_by!(paper: paper)
    score, chosen_list = Assign.score_for(assigs_attributes)
    enroll.update(score: score, chosen_list: chosen_list, hand_in_time: Time.now)
  end
end
