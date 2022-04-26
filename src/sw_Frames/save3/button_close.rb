module SW
  module Frames

    CLOSE_BUTTON = Struct.new(:type, :label, :location, :width, :height,
      :perimeter, :screen_scale, :box_color, :box_toggle_color, :outline_color,
      :text_location, :text_options, :highlight, :toggle, :action, :parent)

    class CLOSE_BUTTON
      include EntityMixin

      def initialize(&block)
        #p 'init button'
        self.type = :Close_Button
        self.label = 'X'
        self.location = nil
        self.width = 20
        self.height = 20
        self.perimeter = []
        self.screen_scale = 1.0
        self.box_color = Sketchup::Color.new(240, 240, 240)
        self.box_toggle_color = Sketchup::Color.new(256, 256, 256)
        self.outline_color = Sketchup::Color.new(240, 240, 240)
        self.text_location = [5, 0]
        self.text_options =  {size: 13, color: [80, 80, 80]}
        self.highlight = false
        self.action = block
        self.parent = nil
      end

    end # button
  end # frame
end



nil




