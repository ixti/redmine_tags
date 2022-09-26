class FixSettingsClass < ActiveRecord::Migration[4.2]
  def up
    new_settings = ActiveSupport::HashWithIndifferentAccess.new
    Setting.plugin_redmine_tags.each do |key, value|
      new_settings[key] = value
    end
    Setting.send "plugin_redmine_tags=", new_settings
  end
end
