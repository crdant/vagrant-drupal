module Puppet::Parser::Functions
  
  newfunction(:stripcomponents) do |args|
    self.interp.newfile(args[0])
    filename = args[0]
    strip_level = args[1]
    raise Puppet::ParseError, "Pathname not provided" if filename.empty?

    components = filename.split(File::SEPARATOR)    
    if ( components.length > strip_level ) then
      components.take(components.length - strip_level).join(File::SEPARATOR)
    end
    
    raise Puppet::ParseError, "${filename} does not have more than ${strip_level} components in its path"

  end
end