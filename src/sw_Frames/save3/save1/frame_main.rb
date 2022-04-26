# A frame - a drawing area that contains buttons, boxes, and of course subframes
#  each enitity

module SW
  module Frames
    class Frame
      attr_accessor(:entities, :parent, :type)
      attr_reader(:frame_entity)

      # saved frame locations
      @@locations = {} unless class_variable_defined?(:@@locations)

      
      ###################
      # initialize the dialog tool 
      # arguments:
      #  id: - a unique name for the dialog
      #  block - optional code block
      #
      #  returns - the dialogtool object
      #
      # If an id: is given the location of the dialog on the screen will be
      # maintained between invocations. If an optional code block is given it
      # will be called with the dialog entity structure as an argument
      #
      
      def initialize(frame_class, close_button, id, block)
        @id = id
        @entities = [] # an array of controls

        # 
        @frame_entity = frame_class.new
        @type = @frame_entity.type
        add_close_button(@frame_entity) if close_button
        
        block.call(@frame_entity) if block
        
        @invalidated = true
        @dragging = false
        
        # restore a saved screen location if present in the @@locations cache
        if @id && @@locations[@id] 
          @frame_entity.location = @@locations[@id]
        end
        
        Sketchup.active_model.active_view.invalidate
        self
      end
      
      def add_close_button(frame_entity)
        entity = SW::Frames::CLOSE_BUTTON.new
        entity.action = method(:close)
        add_entity(entity)
      end
      
      def close()
        @parent.close()
      end
      

      #############################
      # frame dragging
      # and button click functions
      
      def onMouseMove(flags, x, y, view)
        if @dragging
          # move frame
          a, b = @frame_entity.location
          new_location = [a + x - @last_mouse_location[0] , b + y - @last_mouse_location[1]]
          
          # update locations
          @last_mouse_location = [x, y]
          @frame_entity.location = new_location
          @@locations[@id] = new_location if @id
          
          invalidate_frame
          view.invalidate
          
        else
          # check entities for focus and highlighting
          @entities.each{|entity| entity.onMouseMove(flags, x, y, view)}
        end
      end

      # is the mouse over this frame?
      def mouse_over_entity?(view, x, y)
        a, b = @frame_entity.location
        return false unless x > a && x < a + @frame_entity.width
        return false unless y > b && y < b + @frame_entity.height
        true
      end
      
      
      def onLButtonDown(flags, x, y, view)
        # is the mouse over the dialog?
        return unless @frame_entity.mouse_over_entity?(view, x, y)
        
        # any button pressed?
        sel = @entities.select{|entity|
          case entity.type
          when :Frame
            entity.onLButtonDown(flags, x, y, view)
            false
          else
            sel = entity.mouse_over_entity?(view, x, y)
          end
        }

        # execute user code if the mouse is over a button
        if sel[0]
          UI.start_timer(0, false) { sel[0].action.call } if sel[0].action
        else
          @dragging = true
          @last_mouse_location = [x, y]
        end
      end
      
      def onLButtonUp(flags, x, y, view)
        @dragging = false
        @entities.each{|entity|
          case entity.type
          when :Frame
            entity.onLButtonUp(flags, x, y, view)
          end
        }
      end
      
  
      ###################################
      #  Draw routines
      ###################################
      
      def draw(view)
        #draw the dialog window
        @frame_entity.draw_entity(view, @frame_entity.screen_scale, invalidated?)
 
        # flow the rest of the controls
        frame_offset = 0 
        x, y = @frame_entity.location
        x += 10
        y += 5
        y += 2 * @frame_entity.text_options[:size] if @frame_entity.label
        
        # Layout the entites on the dialog
        # call draw entity on each entity
        # invalidated? signals that the dialog has moved on the screen
        
        @entities.each{|entity|
          case entity.type 
          when :Frame
            i, j = @frame_entity.location
            entity.location = [i + 2 + frame_offset, j + 4]
            #entity.frame_entity.draw_entity(view, @frame_entity.screen_scale, invalidated?)
            entity.draw(view)
            frame_offset += 180
          
          when :Close_Button
            i, j = @frame_entity.location
            entity.location = [i + @frame_entity.width - entity.width - 4, j + 4]
            entity.draw_entity(view, @frame_entity.screen_scale, invalidated?)
            
          when :Button
            entity.location = [x, y]
            y += entity.height + 2
            entity.draw_entity(view, @frame_entity.screen_scale, invalidated?)
          end
        }
        
        validate_dialog()
      end # draw
      
      def invalidate_frame()
        @invalidated = true
      end

      def validate_dialog()
        @invalidated = false
      end
      
      def invalidated?()
        @invalidated
      end

      def add_entity(entity)
        @entities << entity
        #adjust_dialog_size()
        invalidate_frame
      end
      
      # set new window location
      def location=(loc)
        @frame_entity.location = loc
        invalidate_frame
        end
      
      # set new window location
      def location()
        @frame_entity.location
        end
      
      def width=(width)
        @frame_entity.width = width
        invalidate_frame
      end 

      def width()
        @frame_entity.width
      end 

      def height=(height)
        @frame_entity.height = height
        invalidate_frame
      end 
      
      def height()
        @frame_entity.height
      end 
      
      
    end # frame
  end
end


nil




