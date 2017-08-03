class SyncOrganizationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "sync_organizations_channel"
  end

  def unsubscribed
  end
end
