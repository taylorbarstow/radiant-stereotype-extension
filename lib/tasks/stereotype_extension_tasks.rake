namespace :radiant do
  namespace :extensions do
    namespace :stereotype do
      
      desc "Runs the migration of the Stereotype extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          StereotypeExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          StereotypeExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Stereotype to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from StereotypeExtension"
        Dir[StereotypeExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(StereotypeExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
      
      desc "Migrate from custom fields implementation to real field implementation"
      task :migrate_from_custom_fields => :environment do
        unless defined?(CustomField)
          class CustomField < ActiveRecord::Base
            belongs_to :page
          end
        end
        
        CustomField.find_all_by_name('stereotype').each do |field|
          field.page.update_attributes!(:stereotype => field.value) if field.page
        end
        
        puts "Now safe to remove the custom fields extension if you don't need it anymore"
      end
    end
  end
end
