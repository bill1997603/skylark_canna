class PublishPaperJob < ApplicationJob
  queue_as :default

  def perform(paper, organizations_list = nil)
    if organizations_list
      paper.user_ids = []

      organizations_list.split(';').each do |organization_id|
        organization = Organization.find(organization_id)
        
        SkylarkAdapter.sync_users(organization.uid)
        user_ids = SkylarkAdapter.fetch_members(organization.uid)
        organization.user_ids = user_ids
        organization.save

        paper.user_ids = (paper.user_ids + user_ids).uniq
      end

      paper.save
    end

    message = { title: "您有新有考试：#{paper.title}",
                url: "users/papers/#{paper.code}/new",
                supplement: "截止日期：#{paper.deadline.localtime.strftime('%m月%d日 %H:%M')}" }

    SkylarkAdapter.push(paper.users, message)
  end
end
