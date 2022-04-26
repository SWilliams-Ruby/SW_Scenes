module SW
  module Frames
    module FramesManagerTool_mixin  
    
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
    end
	end
end
