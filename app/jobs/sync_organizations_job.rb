class SyncOrganizationsJob < ApplicationJob
  queue_as :default

  def perform(parent_uid = :root)
    result = SkylarkAdapter.sync_organizations(parent_uid)

    ActionCable.server.broadcast 'sync_organizations_channel', result
  end
end
