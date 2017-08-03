require 'skylark_adapter/skylark'

module SkylarkAdapter
  def self.fetch_organizations(parent_uid, options = {})
    organizations = if parent_uid == :root
                      Organization.root
                    else
                      Organization.find_by(uid: parent_uid).children
                    end

    unless organizations.empty?
      organizations.ids
    else
      _fetch_organizations(parent_uid, options)
    end
  end

  def self.fetch_members(organization_uid, options = {})
    organization = Organization.find_by(uid: organization_uid)

    unless organization.users.empty?
      organization.user_ids
    else
      _fetch_members(organization_uid, options)
    end
  end

  def self.push(users, message, options = {})
    site = CONFIG['app']['site']
    message.update url: "#{site}/#{message[:url]}"
    SkylarkAdapter::Skylark.instance.push(users.pluck(:openid), message, options)
  end

  def self.sync_organizations(parent_uid)
    parent = (parent_uid == :root ? nil : Organization.find_by(uid: parent_uid))

    organizations = if parent
                      parent.children
                    else
                      Organization.root
                    end

    return {} if organizations.empty?

    organizations_params = if parent_uid == :root
                             SkylarkAdapter::Skylark.instance.get_root
                           else
                             SkylarkAdapter::Skylark.instance.get_children(parent_uid)
                           end

    updated_organizations_params = organizations_params.select do |organization_params|
      organization_params['updated_at'] > Time.now.at_beginning_of_day
    end

    updated_organizations_params.each do |organization_params|
      organization = Organization.find_by(uid: organization_params['id'])

      unless organization
        organization = Organization.new(uid: organization_params['id'])
      end
      organization.parent = parent
      organization.name = organization_params['name']
      organization.children_count = organization_params['children_count']
      organization.remote_updated_at = organization_params['updated_at']
      organization.save
    end

    organizations_ids = if parent_uid == :root
                          Organization.root.ids
                        else
                          Organization.find_by(uid: parent_uid).child_ids
                        end
    remote_organizations_ids = Organization.where(uid: organizations_params.pluck('id')).ids
    deleted_organizations_ids = organizations_ids - remote_organizations_ids
    Organization.where(id: deleted_organizations_ids).destroy_all

    updated_organizations = Organization.where(uid: updated_organizations_params.pluck('id'))

    {
      parent_id: parent_uid == :root ? 'root' : parent.id,
      updated_organizations: updated_organizations.to_json(only: [:id, :name, :children_count]),
      deleted_organizations: deleted_organizations_ids
    }
  end

  def self.sync_users(organization_uid)
    organization = Organization.find_by(uid: organization_uid)

    return if organization.users.empty?

    users_params = SkylarkAdapter::Skylark.instance.get_members(organization_uid)
    users_uids = organization.users.pluck(:uid)

    updated_users_params = users_params.select do |user_params|
      user_params['updated_at'] > Time.now.beginning_of_day || !users_uids.include?(user_params['uid'])
    end

    updated_users_params.each do |user_params|
      user = User.find_by(uid: user_params['id'])

      unless user
        user = User.new(uid: user_params['id'])
      end
      user.openid = user_params['openid']
      user.organizations << organization
      user.name = user_params['name']
      user.remote_updated_at = user_params['updated_at']
      user.save
    end

    users_ids = organization.user_ids
    remote_users_ids = User.where(uid: users_params.pluck('id')).ids
    deleted_users_ids = users_ids - remote_users_ids
    User.where(id: deleted_users_ids).destroy_all
  end

  def self._fetch_organizations(parent_uid, options = {})
    organizations_params = if parent_uid == :root
                             SkylarkAdapter::Skylark.instance.get_root(options)
                           else
                             SkylarkAdapter::Skylark.instance.get_children(parent_uid, options)
                           end

    parent = Organization.find_by(uid: parent_uid) unless parent_uid == :root

    organizations_params.map! do |organization_params|
      { uid: organization_params['id'],
        name: organization_params['name'],
        children_count: organization_params['children_count'],
        ancestry: (parent_uid == :root ? nil : parent.child_ancestry),
        remote_updated_at: organization_params['updated_at'] }
    end

    Organization.import organizations_params, validate: true

    Organization.where(uid: organizations_params.pluck(:uid)).ids
  end

  def self._fetch_members(organization_uid, options = {})
    users_params = SkylarkAdapter::Skylark.instance.get_members(organization_uid, options)

    users_params.map! do |user_params|
      { uid: user_params['id'],
        openid: user_params['openid'],
        name: user_params['name'],
        remote_updated_at: user_params['updated_at'] }
    end

    User.import users_params, on_duplicate_key_ignore: true

    user_ids = User.where(uid: users_params.pluck(:uid)).ids
    organization = Organization.find_by(uid: organization_uid)
    organization.user_ids = user_ids
    organization.save

    user_ids
  end

  def self.update_attributes(object, object_attributes)
    if object.remote_updated_at && object.remote_updated_at < object_attributes['updated_at']
      if object.respond_to? :openid
        object.update(name: object_attributes['name'], openid: object_attributes['openid'], remote_updated_at: object_attributes['updated_at'])
      else
        object.update(name: object_attributes['name'], remote_updated_at: object_attributes['updated_at'])
      end
    end
  end

  def self.update_belonging(organization, users)
    redundant_children = organization.user_ids - users
    unless redundant_children.empty?
      User.where(id: redundant_children).delete_all
      Enroll.where(user: redundant_children).delete_all
    end
  end
end
