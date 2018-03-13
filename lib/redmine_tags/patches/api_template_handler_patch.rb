module RedmineTags
  module Patches
    module ApiTemplateHandlerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          class << self
            alias_method_chain :call, :redmine_tags
          end
        end
      end

      module ClassMethods
        def call_with_redmine_tags(template)
          ActionController::Base.view_paths.each do |path|
            begin
              lines = File.readlines("#{path}/#{template.virtual_path}_with_tags.api.rsb")
              template.source.sub!(lines.last, lines.join) unless lines.empty?
            rescue Errno::ENOENT
            end
          end
          call_without_redmine_tags(template)
        end
      end
    end
  end
end

base = Redmine::Views::ApiTemplateHandler
patch = RedmineTags::Patches::ApiTemplateHandlerPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
