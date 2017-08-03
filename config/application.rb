require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Canna
  class Application < Rails::Application
    config.load_defaults 5.1

    config.i18n.default_locale = 'zh-CN'
    config.i18n.available_locales = [:en, 'zh-CN']

    config.active_job.queue_adapter = :sidekiq

    config.autoload_paths << Rails.root.join('lib')
  end
end
