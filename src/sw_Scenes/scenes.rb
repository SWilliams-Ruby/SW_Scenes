# load 'C:\Program Files (x86)\Google\Google SketchUp 8\Plugins\sw_Scenes\scenes.rb'

module SW
	module Scenes
    def self.start()
      unless defined? SW::Frames
        UI.messagebox('SW Scenes requires the extension SW Frames to operate')
      end
 
      if Sketchup.active_model.pages.count == 0
        UI.messagebox('There are no scenes in this model')
        return
      end
      
      # monitor the pages collection for changes
      # Sketchup.active_model.pages.add_observer(self)
      
      layout_content()
    end
    
    # def self.onContentsModified(pages)
      # #puts "onContentsModified: #{pages}"
      # layout_content()
    # end
    
    # add the top frame
    def self.layout_content()
      # (re)activate the tool and set the cursor
      @tool = SW::Frames::FramesManager.activate_tool
      @tool.set_cursor(File.join(PLUGIN_DIR, "cursors", 'scenes pointer.png'), 1, 1)
      pages = Sketchup.active_model.pages

      @tool.close() if pages.count == 0 #
      
      uniq_id = 'scenes-'
      #top_frame = SW::Frames::FramesManager.create_top_level_frame(SW::Frames::FRAME_TRANSPARENT, 'scenes_top', false)
      top_frame = SW::Frames::FramesManager.create_top_level_frame(SW::Frames::FRAME_OUTLINED, 'scenes_top', false)
      # set the auto-hide to true
      top_frame.box_color = Sketchup::Color.new(240, 240, 240, 120)
      top_frame.outline_color = Sketchup::Color.new(180, 180, 180, 0)
      top_frame.hideable = true
      
      # top_frame.set_onClose_callback {
        # #puts 'closing frame'
        # Sketchup.active_model.pages.remove_observer(self)
      # }
      
      # retrieve the screen height
      view = Sketchup.active_model.active_view
      view_height = view.corner(3)[1].to_f
      
      # offset the frames contents
      top_frame.content_offset = [20, 20] 

      # create the first subframe
      sub_frame = SW::Frames::FRAME_TRANSPARENT.new(false, uniq_id.to_sym)
      sub_frame.location = [0,0]
      sub_frame.content_offset = [0, 0] 
      sub_frame.parent = top_frame
      top_frame.add_entity(sub_frame)
      
      # add the 'scene' buttons to the subframe until the it reaches the maximum height
      width = 0
      height = 0.0
      
      # find the longest page name and calculate a pixel width for all of the buttons
      max_text_Length = (pages.max{|a, b| a.name.size  <=> b.name.size}).name.size * 0.70

      pages.each_with_index {|page, index|
        # create a button and associate an action (block of code) to the button
        #entity = SW::Frames::BUTTON_PLAIN.new {|entity| Sketchup.active_model.pages.selected_page=(page); entity.parent.close()}
        entity = SW::Frames::BUTTON_PLAIN.new {|entity| Sketchup.active_model.pages.selected_page=(page)}
        entity.label = page.name
        
                
        # update the sub_frame size
        # p entity
        # p entity.text_options
        # p  entity.text_options['size']
        
        entity.width = max_text_Length * entity.text_options['size']
        #entity.box_color = 'Ivory'
        entity.box_color = Sketchup::Color.new(255,255,248)
        sub_frame.add_entity(entity)
        
        # keep track of the realestate used in the subframe
        size = entity.size
        height += size[1] + 2 # two pixel buffer
        width = width > size[0] ? width : size[0]

        
        sub_frame.width = max_text_Length * entity.text_options['size'] + sub_frame.content_offset[0] 
        sub_frame.height = height
        
        if (height > view_height * 0.8 ) && (index < pages.size - 1) # this is the height limiter
          #start a new frame
          uniq_id = uniq_id + '-'
          sub_frame = SW::Frames::FRAME_TRANSPARENT.new(false, uniq_id.to_sym)
          sub_frame.location = [0,0]
          sub_frame.content_offset = [0, 0] 
          top_frame.add_entity(sub_frame)
          height = 0
          width = 0
        end  
      }
      
      # adjust the top frame width and height
      total_width = 0
      top_frame.entities.each{|e| total_width += e.width + + top_frame.content_offset[0]}
      top_frame.width = total_width  + 30
      
      largest_sub_entity_height = (top_frame.entities.max{|a, b| a.height <=> a.height}).height
      top_frame.height = largest_sub_entity_height + sub_frame.content_offset[1] + 40
		end
    
	end
end

nil
