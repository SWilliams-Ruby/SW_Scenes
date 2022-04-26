# A frame - a drawing area that contains buttons, boxes, and of course subframes
#  each enitity

module SW
  module Frames
    module Frame_Mixin
      attr_accessor(:entities)

      # saved frame locations
      @@locations = {} unless class_variable_defined?(:@@locations)
      
      ###################
      # initialize the dialog tool 
      # arguments:
      #  id: - a unique name for the dialog
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

        # restore a saved screen location if present in the @@locations cache
        if @id && @@locations[@id] 
          self.location = @@locations[@id]
        end
        
        add_close_button(self) if close_button
        block.call(self) if block
        Sketchup.active_model.active_view.invalidate
      end
      
      def add_close_button(frame_entity)
        entity = SW::Frames::CLOSE_BUTTON.new
        entity.action = method(:close)
        add_entity(entity)
      end
      
      def close()
        parent.close()
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
      end

      # is the mouse over this frame?
      def mouse_over_entity?(view, x, y)
        a, b = location
        return false unless x > a && x < a + width
        return false unless y > b && y < b + height
        true
      end
      
      
      def onLButtonDown(flags, x, y, view)
        # is the mouse over this frame?
        return false unless self.mouse_over_entity?(view, x, y)
        
        # any entity pressed?
        over = @entities.select{|entity|
          case entity.type
          when :Frame
            entity.onLButtonDown(flags, x, y, view)
          else
            entity.onLButtonDown(flags, x, y, view)
          end
        }

        unless over[0]
          @dragging = true
          @last_mouse_location = [x, y]
        end
        
        over[0] # pass this value up the call chain
      end
      
      # currently this doesn't do a thing
      def onLButtonUp(flags, x, y, view)
        @dragging = false
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
        frame_offset = 0 
        x, y = location
        x += 10
        y += 5
        y += 2 * text_options[:size] if label
        
        # call draw entity on each entity
        @entities.each{|entity|
          case entity.type 
          when :Frame
            i, j = location
            entity.location = [i + 2 + frame_offset, j + 4]
            entity.invalidate_frame if invalidated?
            entity.draw(view)
            frame_offset += 180
          
          when :Close_Button
            i, j = location
            entity.location = [i + width - entity.width - 4, j + 4]
            entity.draw_entity(view, screen_scale, invalidated?)
            
          when :Button
            entity.location = [x, y]
            y += entity.height + 2
            entity.draw_entity(view, screen_scale, invalidated?)
          end
        }
        
        validate_frame()
      end # draw
      
      def invalidate_frame()
        @invalidated = true
      end

      def validate_frame()
        @invalidated = false
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
    
    end # frame
  end
end


nil




