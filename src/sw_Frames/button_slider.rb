# the slider entity hasn't been implemented yhet

module SW
  module Frames
    class BUTTON_TOGGLE < BUTTON
      include EntityMixin

      def initialize(&block)
        #p 'init toggle'
        self.type = :Button
        self.label = nil
        self.location = [0,0]
        self.width = 120
        self.height = 22
        self.perimeter = []
        self.screen_scale = 1.0
        self.box_color = Sketchup::Color.new(256, 256, 256)
        self.toggle_color = Sketchup::Color.new('dimgray')
        self.outline_color = Sketchup::Color.new(180, 180, 180)
        self.text_location = [5, 0]
        self.text_options =  {'size' => 13, 'color' => [80, 80, 80]}
        self.highlight = false
        self.toggle = false
        self.action = block
        self.parent = nil
      end
      
      def onLButtonDown(flags, x, y, view)
        if mouse_over_entity?(view, x, y)
          self.toggle = !self.toggle
          UI.start_timer(0, false) { action.call } if action
          view.invalidate
          return self
        else
          return false
        end
      end
       
      def draw_entity(view, scale, invalidated)
        get_perimeter() if invalidated 
        get_marker() if invalidated 

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
            point = Geom::Point3d.new((x + self.height + self.text_location[0]) * scale,  y + self.text_location[1] * scale, 0)
            view.draw_text(point, self.label, self.text_options)
        end
         
        # Draw the value marker  
        tr = Geom::Transformation.translation([ self.location[0] + 10,  self.location[1] + self.height/2, 0])
        orb_perimeter = @orb.collect{|pt| pt.transform(tr)}
        view.drawing_color = self.toggle_color
        if self.toggle 
          view.draw2d(GL_POLYGON, orb_perimeter)
        else
          view.draw2d(GL_LINE_LOOP, orb_perimeter)
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

        self.perimeter = scale_and_translate(roundedgebox, width, self.height, self.screen_scale, self.location)
      end
      
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
      
            
    
      # make the dot indicator
      def get_marker()
        radius = (self.height/2.0) - 5
        center = Geom::Point3d.new(0, 0, 0)
        rotate_around_vector = Geom::Vector3d.new(0, 0, 1)
        angle = 14.4.degrees
        tr = Geom::Transformation.rotation(center, rotate_around_vector, angle)
        vector = Geom::Vector3d.new(radius, 0, 0)
        @orb = 26.times.map {center + vector.transform!(tr) }
      end
      
    end # button
  end # frame
end



nil




