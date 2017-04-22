class EnableForAllProjectsMigration < ActiveRecord::Migration
    def up

        # Do not migrate for new installations
        if ActsAsTaggableOn::Tag.count == 0
            return
        end

        # Do not migrate if a project already has Redmine Tags enabled
        Project.all.each do |p|
            if p.module_enabled?(:tags)
                puts "Some projects have Tags already enabled. Not enabling Tags for all projects"
                return
            end
        end

        puts '********' * 10
        puts 'Redmine Tags now supports enabling tagging per project, and a permission per role'
        puts 'to edit tags. This script can help you migrate to this new functionality.'
        puts ''
        puts 'There are two possible migration scenarios:'
        puts '1. Enable Tags for all projects, and give edit permissions to all roles.'
        puts '   This leaves the functionality of Redmine Tags as before the introduction of'
        puts '   permissions and per-project settings.'
        puts '2. Do not enable Tags for any project, and do not give edit permissions'
        puts '   to any role. Instead, you must enable Tags for specific projects manually'
        puts '   and give permissions to roles manually. In this case, tags will not be visible on'
        puts '   issues until Tags is enabled again for that project. No user can edit tags'
        puts '   until their role has the permission to edit tags.'
        puts 'Select option 1 if you are satisfied with the current way Redmine Tags works, and like'
        puts 'keep it that way. Select option 2 for a greater influence on how you want to set up'
        puts 'Redmine Tags.'
        puts 'Note that for new projects and new roles, Tags and the edit permissions must be'
        puts 'enabled when creating the project/role.'
        puts ''
        puts '1. Enable for all projects/roles'
        puts '2. Do not enable for any project/role, but let me do it manually'
        puts 'Choose your migration scenario [1,2]:'

        input = STDIN.gets.chomp

        while !(input == '1' or input == '2')
            puts 'Invalid choice. Please enter 1 or 2'
            input = STDIN.gets.chomp
        end

        if input == '1'
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

            Role.all.each do |r|
                enabled_permissions = r.permissions
                if !enabled_permissions.include?(:issue_edit_tags)
                    enabled_permissions.push(:issue_edit_tags)
                end
                if !enabled_permissions.include?(:wiki_edit_tags)
                    enabled_permissions.push(:wiki_edit_tags)
                end

                r.permissions = enabled_permissions
                if r.save
                    puts "Enable edit tag permissions for " + r.name
                else
                    puts "Failed to enable tag permissions for " + r.name
                end
            end
        else
            puts ''
            puts 'Please remember to enable the Tags module for your projects, and give'
            puts 'permission to roles who should be able to edit tags.'
        end
    end
end