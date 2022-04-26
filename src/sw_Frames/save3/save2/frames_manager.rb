
module SW
  module Frames
    module FramesManager
      @active = false
      @tool = nil
      @active_frames = {}
      
      def self.create_top_level_frame(frame_class, id, close_button = false,  &block)
        @tool = FramesManagerTool.new(self) unless @tool
        Sketchup.active_model.tools.push_tool(@tool) unless @active
        @active = true

        top_level_frame = frame_class.new(close_button, id){|frame| block.call(frame) if block}
        top_level_frame.parent = @tool
        @active_frames[id] = top_level_frame
        top_level_frame
      end
      
      def self.active_frames()
        @active_frames
      end

      def self.reset_active_frames()
        @active_frames = {}
      end
      
      def self.delete(id)
        @active_frames.delete(id)
      end
      
      def self.find(id)
        @active_frames[id]
      end
      
      def self.update_frames(view)
        @active_frames.each_value{|frame| frame.draw(view)}
      end
      
      def self.active()
        @active
      end

      def self.tool()
        @tool
      end

      def self.active=(active)
        @active = active
      end
   
      class FramesManagerTool
      
        def initialize(frames_manager)
          @frames_manager = frames_manager
        end
          
        def activate
          #puts 'activate'
        end

        def deactivate(view)
          # puts 'deactivate'
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
        
        def onMouseMove(flags, x, y, view)
          @frames_manager.active_frames.each_value{|frame| frame.onMouseMove(flags, x, y, view)}
        end
        
        def onLButtonDown(flags, x, y, view)
          @frames_manager.active_frames.each_value{|frame| frame.onLButtonDown(flags, x, y, view)}
        end
        
        def onLButtonUp(flags, x, y, view)
          @frames_manager.active_frames.each_value{|frame| frame.onLButtonUp(flags, x, y, view)}
        end
        
        def draw(view)
          @frames_manager.active_frames.each_value{|frame| frame.draw(view)}
        end
        
        def close()
          @frames_manager.active = false
          Sketchup.active_model.tools.pop_tool()
          Sketchup.active_model.active_view.invalidate
        end
      end # tool
      
    end # FramesManager
  end # Frames
end


nil




