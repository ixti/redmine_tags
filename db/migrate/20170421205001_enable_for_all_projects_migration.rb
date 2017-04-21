class EnableForAllProjectsMigration < ActiveRecord::Migration
    def up
        Project.all.each do |p|
            if p.module_enabled?(:tags)
                puts "Some projects have Tags already enabled. Not enabling Tags for all projects"
                return
            end
        end

        Project.all.each do |p|
            enabled_module_names = p.enabled_module_names
            if !enabled_module_names.include?(:tags)
                enabled_module_names.push(:tags)
            end

            p.enabled_module_names = enabled_module_names
            if p.save
                puts "Enable Tags for " + p.name
            else
                puts "Failed to enable Tags for " + p.name
            end
        end
    end
end