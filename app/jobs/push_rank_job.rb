class PushRankJob < ApplicationJob
  queue_as :default

  def perform(paper, type = 0, period = nil)
    case type
    when 0
      message = { title: "请查看您在#{paper.title}中的排名",
                  url: "users/papers/#{paper.id}/ranking",
                  supplement: "请及时查看" }
    when 1
      message = { title: "请查看个人排名",
                  url: "users/ranking/individual?period=#{period}",
                  supplement: "请及时查看" }
    when 2
      message = { title: "请查看公司排名",
                  url: "users/ranking/company?period=#{period}",
                  supplement: "请及时查看" }
    end

    if type == 0
      SkylarkAdapter.push(paper.users, message)
    else
      SkylarkAdapter.push(User.where.not(openid: nil), message)
    end
  end
end
