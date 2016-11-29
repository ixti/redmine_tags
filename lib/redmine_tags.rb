module RedmineTags
  def self.settings
    ActionController::Parameters.new(Setting[:plugin_redmine_tags])
  end
end
