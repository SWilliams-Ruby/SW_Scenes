module SW
  module Frames
    class BUTTON_PLAIN < BUTTON 
      include EntityMixin
      
      def initialize(&block)
        #p 'init button'
        self.type = :Button
        self.label = nil
        self.location = [0,0]
        self.width = 120
        self.height = 22
        self.perimeter = []
        self.screen_scale = 1.0
        self.box_color = Sketchup::Color.new(256, 256, 256)
        self.outline_color = Sketchup::Color.new(180, 180, 180)
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




