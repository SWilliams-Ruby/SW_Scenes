#-------------------------------------------------------------------------------
#
#
#-------------------------------------------------------------------------------

require "extensions.rb"

module SW
module Frames

  path = __FILE__
  path.force_encoding("UTF-8") if path.respond_to?(:force_encoding)

  PLUGIN_ID = File.basename(path, ".rb")
  PLUGIN_DIR = File.join(File.dirname(path), PLUGIN_ID)
  EXTENSION = SketchupExtension.new(
    "SW Frame Interface",
    File.join(PLUGIN_DIR, "loader")
  )
  EXTENSION.creator     = "S. Williams"
  EXTENSION.description = "A Sketchup/Ruby Frame Interface"
  EXTENSION.version     = "1.0.0"
  EXTENSION.copyright   = "#{EXTENSION.creator} Copyright (c) 2019"
  Sketchup.register_extension(EXTENSION, true)

end
end

