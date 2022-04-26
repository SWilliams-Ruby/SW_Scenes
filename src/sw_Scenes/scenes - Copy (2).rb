module SW
	module Scenes
		def self.start()
      unless defined? SW::Frames
        UI.messagebox('SW Scenes requires the extension SW Frames to operate')
      end

      model = Sketchup.active_model
      pages = model.pages
      
      if pages.count == 0
        UI.messagebox('There are no scenes in this model')
        return
      end
      
      uniq_id = 'scenes-'
      top_frame = SW::Frames::FramesManager.create_top_level_frame(SW::Frames::FRAME_TRANSPARENT, 'scenes_top', false)
      top_frame.width = 1000
      top_frame.height = 700

      sub_frame = SW::Frames::Frame.new(SW::Frames::FRAME_TRANSPARENT, false, uniq_id.to_sym, nil)
      sub_frame.location = [0,0]
      sub_frame.parent = top_frame
      
      top_frame.add_entity(sub_frame)
      
      width = 0
      height = 0
      
      view = Sketchup.active_model.active_view
      view_height = view.corner(3)[1]

      pages.each {|page|
        entity = SW::Frames::BUTTON.new {Sketchup.active_model.pages.selected_page=(page)}
        entity.label = page.name
        entity.width = 160
        entity.box_color = 'Ivory'
        sub_frame.add_entity(entity)
        size = entity.size
        height += size[1] + 2
        width = width > size[0] ? width : size[0]
        
        if height > view_height / 5 
          # finish the current frame
          sub_frame.width = width + 20
          sub_frame.height = height + 20

          #start a new frame
          uniq_id = uniq_id + '-'
          sub_frame = SW::Frames::Frame.new(SW::Frames::FRAME_TRANSPARENT, false, uniq_id.to_sym, nil)
          top_frame.add_entity(sub_frame)
          height = 0
          width = 0
        end  

        sub_frame.width = width + 20
        sub_frame.height = height + 20
      }
      


		end
	end
end
