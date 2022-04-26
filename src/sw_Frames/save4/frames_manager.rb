
module SW
  module Frames
    module FramesManager
      @active = false
      @tool = nil
      @active_frames = {}
      
      def self.create_top_level_frame(frame_class, id, close_button = false,  &block)
        top_level_frame = frame_class.new(close_button, id){|frame| block.call(frame) if block}
        top_level_frame.parent = @tool
        @active_frames[id] = top_level_frame
        top_level_frame
      end
      
      def self.activate_tool()
        @tool = FramesManagerTool.new(self) unless @tool
        Sketchup.active_model.tools.push_tool(@tool) unless @active
        @tool.show() # the tool may have already been the active tool
        @active = true
        @tool
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
      
      def self.activate_frame(id)
        frame = @active_frames[id]
        @active_frames << frame if frame
        frame
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
   
    end # FramesManager
  end # Frames
end


nil




