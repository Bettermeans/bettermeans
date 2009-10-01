module RedmineS3
  module AttachmentsControllerPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
 
      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        before_filter :redirect_to_s3, :except => :destroy
        skip_before_filter :file_readable
      end
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
      def redirect_to_s3
        if @attachment.container.is_a?(Version) || @attachment.container.is_a?(Project)
          @attachment.increment_download
        end
        redirect_to("#{RedmineS3::Connection.uri}/#{@attachment.disk_filename}")
      end
    end
  end
end
