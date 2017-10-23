# frozen_string_literal: true

require 'redmine_tags'

# ActiveSupport::Reloader for rails >= 5
# ActionDispatch::Callbacks for rails < 5
reloader = defined?(ActiveSupport::Reloader) ? ActiveSupport::Reloader : ActionDispatch::Callbacks

reloader.to_prepare do
  paths = '/lib/redmine_tags/{patches/*_patch,hooks/*_hook}.rb'
  Dir.glob(File.dirname(__FILE__) + paths).each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_tags do
  name        'Redmine Tags'
  author      'Aleksey V Zapparov AKA "ixti"'
  description 'Redmine tagging support'
  version     '3.2.1'
  url         'https://github.com/ixti/redmine_tags/'
  author_url  'http://www.ixti.net/'

  requires_redmine version_or_higher: '3.0.0'

  settings \
    default:  {
      issues_sidebar:    'none',
      issues_show_count: 0,
      issues_open_only:  0,
      issues_sort_by:    'name',
      issues_sort_order: 'asc'
    },
    partial: 'tags/settings'
end

Rails.application.config.after_initialize do
  test_dependencies = {
    # TODO: do not depend on this for tests.
    redmine_testing_gems: '1.3.3'
  }
  current_plugin = Redmine::Plugin.find(:redmine_tags)
  check_dependencies = proc do |plugin, version|
    begin
      current_plugin.requires_redmine_plugin(plugin, version)
    rescue Redmine::PluginNotFound
      raise Redmine::PluginNotFound,
        "Redmine Tags depends on plugin: #{plugin} version: #{version}"
    end
  end
  test_dependencies.each(&check_dependencies) if Rails.env.test?
end
