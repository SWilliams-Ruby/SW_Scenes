require File.join(SW::Scenes::PLUGIN_DIR, 'sw_Frames_for_Scenes', 'loader')
require File.join(SW::Scenes::PLUGIN_DIR, 'scenes.rb')

module SW
  module Scenes
    def self.load_menus()
          
      # Load Menu Items  
      if !@loaded
        toolbar = UI::Toolbar.new "SW Scenes Bar"
        
        cmd = UI::Command.new("Thirds") {SW::Scenes.start}
        cmd.large_icon = cmd.small_icon =  File.join(SW::Scenes::PLUGIN_DIR, "icons/icon.png")
        cmd.tooltip = "Click to show Scenes"
        cmd.status_bar_text = "Show Scenes"
        # cmd.set_validation_proc {
          # print 'v'
          # if Sketchup.active_model.selection.length == 0
            # MF_GRAYED
          # else
            # MF_ENABLED
          # end
        # }
        toolbar = toolbar.add_item cmd
        toolbar.show
        
        
        UI.menu("View").add_item("SW Scenes") {SW::Scenes.start}
        

        
      @loaded = true
      end
    end
    load_menus()
  end
  
end
