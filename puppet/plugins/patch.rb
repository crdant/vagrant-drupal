module Puppet
  require 'puppet/network/client'

  newtype(:patch) do
    @doc = "Applies a Unix patchfile.

    patch { "change.patch": 
      file  => "/path/to/original/file",
      relative => 0,
    }

    which is the equivalent of running 

    $ patch -p0 /path/to/original/file change.patch

    on the commandline"

    newparam(:patch) do
      desc "The patchfile to apply"
      isnamevar
    end

    newparam(:level) do
      desc "The number of path components to strip from the filenames in the patch."
      
    end
    
    newproperty (:file) do      
      def sync
        @output, status = @resource.run("patch -p" + :level + " " + :patch)
        if status.exitstatus.to_s != "0"
            self.fail("patch was not applied, patch command returned %s instead of %s" %
                [status.exitstatus, "0"])
        end
      end
    end
    
  end
    
end