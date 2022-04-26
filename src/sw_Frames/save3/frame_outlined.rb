
module SW
  module Frames
  
    # Entity Structure with default values
    FRAME_OUTLINED = Struct.new(:type, :label, :location, :width, :height,
      :perimeter, :screen_scale, :box_color, :outline_color,
      :text_location, :text_options, :highlight, :action, :parent)
      
    class FRAME_OUTLINED
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
        super # init mixin
      end
      
      def draw_entity(view, scale, invalidated)
        get_perimeter() if invalidated 

        # Background
        view.drawing_color = self.box_color
        view.draw2d(GL_POLYGON, self.perimeter)

        # Outline
        view.line_stipple = '' # Solid line
        view.line_width = 1
        view.drawing_color = self.outline_color
        view.drawing_color = Sketchup::Color.new "Blue" if self.highlight
        view.draw2d(GL_LINE_LOOP, self.perimeter)
        
        # Bar Background
        x = self.location[0] * scale
        y = self.location[1] * scale
        
        # Label
        if self.label
            point = Geom::Point3d.new(x + self.text_location[0] * scale,  y + self.text_location[1] * scale, 0)
            view.draw_text(point, self.label, self.text_options)
        end
      end
      
      # 
      def get_perimeter()
        # a 1x1 rounded edge box
        roundedgebox = [[0.125, 0.0, 0.0], [0.875, 0.0, 0.0], [0.922835, 0.009515, 0.0],\
          [0.963388, 0.036612, 0.0], [0.990485, 0.077165, 0.0], [1.0, 0.125, 0.0],\
          [0.990485, 0.922835, 0.0], [0.963388, 0.963388, 0.0], [0.922835, 0.990485, 0.0],\
          [0.875, 1.0, 0.0], [0.875, 1.0, 0.0], [0.077165, 0.990485, 0.0], [0.036612, 0.963388, 0.0],\
          [0.009515, 0.922835, 0.0], [0.0, 0.875, 0.0], [0.0, 0.875, 0.0], [0.009515, 0.077165, 0.0],\
          [0.036612, 0.036612, 0.0], [0.077165, 0.009515, 0.0], [0.125, 0.0, 0.0]]

        self.perimeter = scale_and_translate(roundedgebox, self.width, self.height, self.screen_scale, self.location)
      end
      
      #### This algorithm works well for small boxes but needs improvrmrnt for the bigguns
      
      # scale uniformly by the height value and scootch the right side 
      # points over to the correct width. Move to location on screen  
      def scale_and_translate(outline, width, height, scale, location)
        tr = Geom::Transformation.scaling(height * scale, height * scale,0)
        outline.collect!{|pt|
          pt.transform!(tr)
          pt[0] = pt[0] + width * scale - height * scale if pt[0] > height * scale/2
          pt
        }
        tr = Geom::Transformation.translation([location[0] * scale, location[1] * scale])
        outline.collect{|pt| pt.transform(tr)}
      end
      
      
    end # FRAME_OUTLINED
  end
end


nil




