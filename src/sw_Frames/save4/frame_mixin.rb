# 1da13406-7172-4f17-b736-15b2dd927521

# A frame - a drawing area that contains buttons, boxes, and of course subframes
#  each enitity

module SW
  module Frames
    # Frame Structure
    FRAME = Struct.new(:type, :label, :location, :content_offset, :width, :height,
      :perimeter, :screen_scale, :box_color, :outline_color,
      :text_location, :text_options, :highlight, :action, :parent, :hideable)
      
    module Frame_Mixin
      attr_accessor(:entities)

      # saved frame locations
      @@locations = {} unless class_variable_defined?(:@@locations)
      
      ###################
      # initialize the frameool 
      # arguments:
      #  close_button - 
      #  id - a unique name for the dialog
      #  block - optional code block
      #
      # If an id: is given the location of the dialog on the screen will be
      # maintained between invocations. If an optional code block is given it
      # will be called with the frame object structure as an argument
      #
      
      def initialize(close_button, id, &block)
        @id = id
        @invalidated = true
        @dragging = false
        @entities = [] # an array of controls
        @onClose_callback = nil

        # restore a saved screen location if present in the @@locations cache
        if @id && @@locations[@id] 
          self.location = @@locations[@id]
        end
        
        add_close_button(self) if close_button
        block.call(self) if block
        Sketchup.active_model.active_view.invalidate
      end
      
      def to_s()
        "<#{self.class}:#{self.object_id.to_s(16)}>"
      end
      
      def inspect()
        "<#{self.class}:#{self.object_id.to_s(16)}>"
      end
      
      
      def add_close_button(frame_entity)
        entity = SW::Frames::CLOSE_BUTTON.new
        entity.action = method(:close)
        add_entity(entity)
      end
      
      def close()
        parent.close()
      end
      
      def set_onClose_callback(&block)
        @onClose_callback = block
      end
      
      def call_onClose_callback()
        @onClose_callback.call if @onClose_callback
      end

      
      def validate_frame()
        @invalidated = false
      end
           
      def invalidate_frame()
        @invalidated = true
      end
      
      def invalidated?()
        @invalidated
      end

      def add_entity(entity)
        entity.parent = self
        @entities << entity
        #adjust_dialog_size()
        invalidate_frame
      end
      def entities()
        @entities
      end
      
      def remove_entity(entity)
        @entities.delete(entity)
      end 
      
      def clear_entities()
        @entities = []
      end
            
      def size()
        [self.width, self.height]
      end
 
      #############################
      # frame dragging
      # and button click functions
      
      def onMouseMove(flags, x, y, view)
        if @dragging
          # move frame
          a, b = location
          new_location = [a + x - @last_mouse_location[0] , b + y - @last_mouse_location[1]]
          
          # update locations
          @last_mouse_location = [x, y]
          self.location = new_location
          @@locations[@id] = new_location if @id
          invalidate_frame
          view.invalidate
        else
          # touch each entity for focus and highlighting
          @entities.each{|entity| entity.onMouseMove(flags, x, y, view)}
        end
        mouse_over_entity?(view, x, y)
      end

      # is the mouse over this frame?
      def mouse_over_entity?(view, x, y)
        a, b = location
        return false unless x > a && x < a + width
        return false unless y > b && y < b + height
        true
      end
      
      
      def onLButtonDown(flags, x, y, view)
        #puts "call lbdown #{self}"
        # is the mouse over this frame?
        return false unless self.mouse_over_entity?(view, x, y)
        
        # any entity pressed?
        clicked = @entities.collect{|entity|
          #puts "lbdown entity #{entity}"
          case entity.type
          when :Frame
            entity.onLButtonDown(flags, x, y, view)
          else
            entity.onLButtonDown(flags, x, y, view)
          end
        }
        clicked.compact!
        # puts "clicked #{clicked}"
        unless clicked[0] 
          @dragging = true
          self.highlight = true
          invalidate_frame()
          view.invalidate
          @last_mouse_location = [x, y]
          return self # pass this value up the call chain
        else
          return clicked[0] # pass this value up the call chain
        end
      end
      
      # currently this doesn't do a thing
      def onLButtonUp(flags, x, y, view)
        @dragging = false
        if self.highlight
          self.highlight = false
          invalidate_frame()
          view.invalidate
        end
        
        @entities.each{|entity|
          case entity.type
          when :Frame
            entity.onLButtonUp(flags, x, y, view)
          else
            entity.onLButtonUp(flags, x, y, view)
          end
        }
        
        
        
      end
      
      
  
      ###################################
      #  Draw routines
      ###################################
      
      def draw(view)
        #draw the dialog window
        draw_entity(view, screen_scale, invalidated?)
        
        # flow the rest of the controls
        self.content_offset
        frame_offset_x = self.content_offset[0] 
        frame_offset_y = self.content_offset[1] 
        i, j = self.location
        x, y = self.location
        
        if label
          y += 2 * text_options[:size] 
        else 
          y += self.content_offset[1]
        end

        # call draw entity on each entity
        @entities.each{|entity|
          case entity.type 
          when :Frame
            entity.location = [i + frame_offset_x, j + frame_offset_y]
            entity.invalidate_frame if invalidated?
            entity.draw(view)
            frame_offset_x += entity.width + self.content_offset[0] 
          
          when :Close_Button
            entity.location = [i + width - entity.width - 4, j + 4 ]
            entity.draw_entity(view, screen_scale, invalidated?)
            
          when :Button
            entity.location = [x + self.content_offset[0], y]
            y += entity.height + 2
            entity.draw_entity(view, screen_scale, invalidated?)
          end
        }
        
        validate_frame()
      end # draw
 
    
    end # frame
  end
end


nil




