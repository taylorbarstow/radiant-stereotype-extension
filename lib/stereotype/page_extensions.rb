module Stereotype
  module PageExtensions
    
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        class <<self
          alias_method_chain :new_with_defaults, :stereotype
        end
      end
    end
    
    module ClassMethods
      def new_with_defaults_with_stereotype(config = Radiant::Config)
        page = new
        parent_list = find_by_sql ['select * from pages where id=?', page.parent_id]
        name = parent_list.first.stereotype unless parent_list.empty?
      
        if name
          parts_and_filters = config["stereotype.#{name}.parts"].blank? ? config["defaults.page.parts"].to_s.strip.split(',') : config["stereotype.#{name}.parts"].to_s.strip.split(',')
          parts_and_filters.each do |part_and_filter|
            part_filter = part_and_filter.to_s.split(':')
            
            st_name = part_filter[0].nil? ? "" : part_filter[0]
            st_filter = part_filter[1].nil? ? "" : part_filter[1].gsub('_', ' ').capitalize
            page.parts << PagePart.new(:name => st_name, :filter_id => st_filter)
          end
      
          st_layout = Layout.find_by_name(config["stereotype.#{name}.layout"])
          st_layout_id = st_layout.nil? ? nil : st_layout.id
          page.layout_id = st_layout_id if st_layout_id
      
          st_class_name = config["stereotype.#{name}.page_type"]
          page.class_name = st_class_name if st_class_name
          
          st_status = config["stereotype.#{name}.status"]
          page.status = Status[st_status] if st_status
          
          st_stereotype = config["stereotype.#{name}.stereotype"]
          page.stereotype = st_stereotype if st_stereotype
          
          page
        else
          new_with_defaults_without_stereotype(config)
        end
      end
    end
  end
end