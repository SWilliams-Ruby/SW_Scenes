
module SW
  module FramesForScenes
    class FRAME_OUTLINED < FRAME
      include Frame_Mixin
      
      def initialize(close_button, id, &block)
        self.type = :Frame
        self.label = nil
        self.location = [50, 30]
        self.content_offset = [10, 5] 
        self.width = 300
        self.height = 60
        self.perimeter = []
        self.screen_scale = 1.0
        self.box_color = Sketchup::Color.new(240, 240, 240)
        self.outline_color = Sketchup::Color.new(180, 180, 180)
        self.text_location = [10, 4]
        self.text_options =  {'size' => 13, 'color' => [80, 80, 80]}
        self.highlight = false
        self.action = nil
        self.parent = nil
        self.hideable = false
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
        view.drawing_color = Sketchup::Color.new "Gray" if self.highlight
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
        # a 4x4 rounded edge box
        roundedgebox = [[0.0, 3.875, 0.0], [0.001069, 0.108684, 0.0], [0.004259, 0.092648, 0.0], [0.009515, 0.077165, 0.0], [0.016747, 0.0625, 0.0], [0.025831, 0.048905, 0.0], [0.036612, 0.036612, 0.0], [0.048905, 0.025831, 0.0], [0.0625, 0.016747, 0.0], [0.077165, 0.009515, 0.0], [0.092648, 0.004259, 0.0], [0.108684, 0.001069, 0.0], [0.125, 0.0, 0.0], [0.125, 0.0, 0.0], [3.891316, 0.001069, 0.0], [3.907352, 0.004259, 0.0], [3.922835, 0.009515, 0.0], [3.9375, 0.016747, 0.0], [3.951095, 0.025831, 0.0], [3.963388, 0.036612, 0.0], [3.974169, 0.048905, 0.0], [3.983253, 0.0625, 0.0], [3.990485, 0.077165, 0.0], [3.995741, 0.092648, 0.0], [3.998931, 0.108684, 0.0], [4.0, 0.125, 0.0], [4.0, 0.125, 0.0], [3.998931, 3.891316, 0.0], [3.995741, 3.907352, 0.0], [3.990485, 3.922835, 0.0], [3.983253, 3.9375, 0.0], [3.974169, 3.951095, 0.0], [3.963388, 3.963388, 0.0], [3.951095, 3.974169, 0.0], [3.9375, 3.983253, 0.0], [3.922835, 3.990485, 0.0], [3.907352, 3.995741, 0.0], [3.891316, 3.998931, 0.0], [3.875, 4.0, 0.0], [3.875, 4.0, 0.0], [0.125, 4.0, 0.0], [0.108684, 3.998931, 0.0], [0.092648, 3.995741, 0.0], [0.077165, 3.990485, 0.0], [0.0625, 3.983253, 0.0], [0.048905, 3.974169, 0.0], [0.036612, 3.963388, 0.0], [0.025831, 3.951095, 0.0], [0.016747, 3.9375, 0.0], [0.009515, 3.922835, 0.0], [0.004259, 3.907352, 0.0], [0.001069, 3.891316, 0.0]]
        
        self.perimeter = scale_and_translate(roundedgebox, self.width, self.height, self.screen_scale, self.location)
      end
      
      #### This algorithm works well for small boxes but needs improvrmrnt for the bigguns
      
      # scale uniformly by the height value and scootch the right side 
      # points over to the correct width. Move to location on screen  
      def scale_and_translate(outline, width, height, scale, location)
        tr = Geom::Transformation.scaling(height * scale/4, height * scale/4,0)
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




