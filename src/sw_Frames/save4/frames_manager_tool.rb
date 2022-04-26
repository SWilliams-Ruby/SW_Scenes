module SW
  module Frames
    module FramesManager
      
      # Sketchup tool interface methods to abe included in a user's
      # custom tool
      module FramesManagerToolMixin
        
        def initialize(frames_manager)
          @frames_manager = frames_manager
          @default_cursor = UI.create_cursor(File.join(PLUGIN_DIR, "cursors", 'pointer.png'), 1, 7)
        end
          
        def activate
          #puts 'activate'
          @over_frames = {} # mouse over frames
          @hide_delay = 2.0 # 
          @hide_time = Time.now + @hide_delay 
          @hide_frames = false 
          @cursor = @default_cursor
          #@timer = UI.start_timer(0.2, true) {hide()}
        end
        
        # redisplay the frame if it is hidden
        def show()
          Sketchup.active_model.active_view.invalidate if @hide_frames == true
          @hide_frames = false
          @hide_time = Time.now + @hide_delay # set a new hide time
        end
        
        def hide()
          if Time.now > @hide_time
            @hide_frames = true # flag to hide 'hideable' frames
            Sketchup.active_model.active_view.invalidate
          end
        end

        def deactivate(view)
          # puts 'deactivate'
          #UI.stop_timer(@timer)
          @frames_manager.reset_active_frames
          @frames_manager.active = false
          view.invalidate
        end

        def onCancel(reason, view)
          # puts 'conCancel'
          close()
        end
        
        def resume(view)
          # puts 'resume'
          view.invalidate
        end   

        # close is called by 
        # cancel()
        # onLButtonDown()
        # any frame.close(), see frame_mixin.rb
        def close()
          # call all of the frame onClose_callbacks
          @frames_manager.active_frames.each_value{|frame| frame.call_onClose_callback()}
          @frames_manager.active = false
          Sketchup.active_model.tools.pop_tool()
          Sketchup.active_model.active_view.invalidate
        end
        
        def onMouseMove(flags, x, y, view)
          @over_frames = @frames_manager.active_frames.select{|k, v| v.onMouseMove(flags, x, y, view)}

          # show the frame again if the mouse rolls over it.
          if @over_frames.size > 0
            view.invalidate if @hide_frames == true
            @hide_frames = false
            @hide_time = Time.now + @hide_delay # set a new hide time
          end
            
        end
        
        def onLButtonDown(flags, x, y, view)
          over = @frames_manager.active_frames.collect{|k, v| r = v.onLButtonDown(flags, x, y, view)}
          # puts "FramesManagerToolMixin: #{over[0]}"
          if over[0] == false
            close()
          end
        end
        
        def onLButtonUp(flags, x, y, view)
          @frames_manager.active_frames.each_value{|frame| frame.onLButtonUp(flags, x, y, view)}
        end
        
        # draw each frame unless -
        # the mouse hasn't moved in @hide_delay seconds
        # and the frame is hideable
        # and the mouse is not on over any frame
        def draw(view)
          @frames_manager.active_frames.each_value{|frame|
            unless @hide_frames && frame.hideable && (@over_frames.size == 0)
              frame.draw(view)
            end
          }
        end

        def set_cursor(path, x, y)
          @cursor = UI.create_cursor(path, x, y)
        end
  
        def onSetCursor
          UI.set_cursor(@cursor)
        end  
        
       
      end # tool
      
           
      # Sketchup Tool class
      class FramesManagerTool
        include FramesManagerToolMixin
      end # tool
      
    end
  end
end