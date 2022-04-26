
module SW
  module Frames
  
    # Entity Structure with default values
    FRAME_TRANSPARENT = Struct.new(:type, :label, :location, :width, :height,
      :perimeter, :screen_scale, :box_color, :outline_color,
      :text_location, :text_options, :highlight, :action, :parent)
      
    class FRAME_TRANSPARENT
      include Frame_Mixin
      
      def initialize(close_button, id, &block)
        self.type = :Frame
        self.label = nil
        self.location = [50, 30]
        self.width = 300
        self.height = 60
        self.perimeter = []
        self.screen_scale = 1.0
        self.box_color = Sketchup::Color.new(240, 240, 240)
        self.outline_color = Sketchup::Color.new(180, 180, 180)
        self.text_location = [10, 4]
        self.text_options =  {size: 13, color: [80, 80, 80]}
        self.highlight = false
        self.action = nil
        self.parent = nil
        super
      end
    
      # # is the mouse over this entity
      # # => true/false
      def mouse_over_entity?(view, x, y)
        a, b = self.location
        return false unless x > a && x < a + self.width
        return false unless y > b && y < b + self.height
        true
      end
      
      def draw_entity(view, scale, invalidated)
        # draw nothing
      end
     
      
    end # FRAME_TRANSPARENT
  end
end


nil




