# load 'C:\Program Files (x86)\Google\Google SketchUp 8\Plugins\sw_Scenes\scenes.rb'

module SW
	module Scenes
    def self.start()
      # unless defined? SW::FramesForScenes
        # UI.messagebox('SW Scenes requires the extension SW FramesForScenes for Scenesto operate')
        # return
      # end
 
      if Sketchup.active_model.pages.count == 0
        UI.messagebox('There are no scenes in this model')
        return
      end
      UI.scale_factor
      push_frame_tool()
    end
    
    # activate the frame tool and add sub_FramesForScenes (columns of buttons)
    #
    def self.push_frame_tool()
      frame_tool = activate_frame_tool()
      top_frame = add_top_frame( frame_tool )
      flow_content( top_frame )
      set_top_frame_size( top_frame )
    end
    
    # activate the frame_tool and set the cursor
    #
    def self.activate_frame_tool()
      frame_tool = SW::FramesForScenes::FramesManager.activate_tool
      frame_tool.set_cursor(File.join(PLUGIN_DIR, "cursors", 'scenes pointer.png'), 1, 1)
      frame_tool
    end
    
    # The top level container
    #
    def self.add_top_frame(frame_tool)
      top_frame = SW::FramesForScenes::FramesManager.create_top_level_frame(SW::FramesForScenes::FRAME_OUTLINED, 'scenes_top', false)
      top_frame.box_color = Sketchup::Color.new(240, 240, 240, 120)
      top_frame.outline_color = Sketchup::Color.new(180, 180, 180, 0)
      top_frame.content_offset = [ 20, 20 ]
      top_frame.hideable = true # hide after some time delay
      top_frame
    end
    
    # second level container
    #
    def self.add_subframe( top_frame, uniq_id )
      sub_frame = SW::FramesForScenes::FRAME_TRANSPARENT.new(false, uniq_id.to_sym)
      sub_frame.location = [0,0]
      sub_frame.content_offset = [0, 0] 
      sub_frame.parent = top_frame
      top_frame.add_entity( sub_frame )
      sub_frame  
    end
    
    # Add the 'scene' buttons to the subFramesForScenes until the it reaches the maximum height
    #
    def self.flow_content( top_frame )
      view = Sketchup.active_model.active_view
      view_height = view.corner(3)[1].to_f
      pages = Sketchup.active_model.pages
      uniq_id = 'scenes-'
      #subframe_width = 0
      subframe_height = 0.0
      
      sub_frame = add_subframe( top_frame, uniq_id )
      
      # find the longest page name and calculate a pixel width for all of the buttons
      max_text_Length = (pages.max{|a, b| a.name.size  <=> b.name.size}).name.size * 0.70

      pages.each_with_index {|page, index|
        button = SW::FramesForScenes::BUTTON_PLAIN.new {|button| Sketchup.active_model.pages.selected_page=(page)}
        button.label = page.name
        button.width = max_text_Length * button.text_options[:size]
        button.box_color = Sketchup::Color.new(255,255,248)
        #button.box_color = 'Ivory'
        sub_frame.add_entity(button)
        
        # keep track of the realestate used in the subframe
        size = button.size
        subframe_height += size[1] + 2 # two pixel buffer
        #subframe_width = subframe_width > size[0] ? subframe_width : size[0]
        
        sub_frame.width = max_text_Length * button.text_options[:size] + sub_frame.content_offset[0] 
        sub_frame.height = subframe_height
        
        if (subframe_height > view_height * 0.8 ) && (index < pages.size - 1) # this is the height limiter
          #start a new sub_frame
          uniq_id = uniq_id + '-'
          sub_frame = add_subframe( top_frame, uniq_id )
          subframe_height = 0
          subframe_width = 0
        end  
      }
		end

    def self.set_top_frame_size( top_frame )
      total_width = 0
      top_frame.entities.each{|e| total_width += e.width + top_frame.content_offset[0]}
      top_frame.width = total_width  + 30
      largest_sub_entity_height = (top_frame.entities.max{|a, b| a.height <=> a.height}).height
      top_frame.height = largest_sub_entity_height + 40
    end

    
	end
end

nil
