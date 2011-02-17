# BetterMeans - Work 2.0
# Copyright (C) 2009  Shereef Bishay
#

require "digest/md5"

class Attachment < ActiveRecord::Base
  belongs_to :container, :polymorphic => true
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  
  # validates_presence_of :container #commenting out to allow for temporary attachments uploaded before a new issue is created
  validates_presence_of :filename, :author
  validates_length_of :filename, :maximum => 255
  validates_length_of :disk_filename, :maximum => 255
  
  after_validation :put_to_s3
  before_destroy   :delete_from_s3
  

  acts_as_event :title => :filename,
                :url => Proc.new {|o| {:controller => 'attachments', :action => 'download', :id => o.id, :filename => o.filename}}

  cattr_accessor :storage_path
  unloadable # Send unloadable so it will not be unloaded in development
  attr_accessor :s3_access_key_id, :s3_secret_acces_key, :s3_bucket, :s3_bucket
  
  @@storage_path = "#{RAILS_ROOT}/files"
  
  def validate
    if self.filesize > Setting.attachment_max_size.to_i.kilobytes
      errors.add(:base, :too_long, :count => Setting.attachment_max_size.to_i.kilobytes)
    end
  end
  
  def put_to_s3
    if @temp_file && (@temp_file.size > 0)
      logger.debug("Uploading to #{RedmineS3::Connection.uri}/#{disk_filename}")
      RedmineS3::Connection.put(disk_filename, @temp_file.read)
      RedmineS3::Connection.publicly_readable!(disk_filename)
      md5 = Digest::MD5.new
      self.digest = md5.hexdigest
    end
    @temp_file = nil # so that the model's original after_save block skips writing to the fs
  end

  def delete_from_s3
    if ENV['RACK_ENV'] == 'production'
      logger.debug("Deleting #{RedmineS3::Connection.uri}/#{disk_filename}")
      RedmineS3::Connection.delete(disk_filename)
    end
  end
  

  def file=(incoming_file)
    unless incoming_file.nil?
      @temp_file = incoming_file
      if @temp_file.size > 0
        self.filename = sanitize_filename(@temp_file.original_filename)
        self.disk_filename = Attachment.disk_filename(filename)
        self.content_type = @temp_file.content_type.to_s.chomp
        self.filesize = @temp_file.size
      end
    end
  end
	
  def file
    nil
  end

  # Copies the temporary file to its final location
  # and computes its MD5 hash
  def before_save
    logger.debug("entering before save")
    if @temp_file && (@temp_file.size > 0)
      logger.debug("saving '#{self.diskfile}'")
      md5 = Digest::MD5.new
      File.open(diskfile, "wb") do |f| 
        buffer = ""
        while (buffer = @temp_file.read(8192))
          f.write(buffer)
          md5.update(buffer)
        end
      end
      self.digest = md5.hexdigest
    end
    # Don't save the content type if it's longer than the authorized length
    if self.content_type && self.content_type.length > 255
      self.content_type = nil
    end
  end

  # Deletes file on the disk
  def after_destroy
    File.delete(diskfile) if !filename.blank? && File.exist?(diskfile)
  end

  # Returns file's location on disk
  def diskfile
    "#{@@storage_path}/#{self.disk_filename}"
  end
  
  def increment_download
    increment!(:downloads)
  end

  def project
    container.project
  end
  
  def visible?(user=User.current)
    container.attachments_visible?(user)
  end
  
  def deletable?(user=User.current)
    container.attachments_deletable?(user)
  end
  
  def image?
    self.filename =~ /\.(jpe?g|gif|png)$/i
  end
  
  def is_text?
    Redmine::MimeType.is_type?('text', filename)
  end
  
  def is_diff?
    self.filename =~ /\.(patch|diff)$/i
  end
  
  # Returns true if the file is readable
  def readable?
    File.readable?(diskfile)
  end
  
private
  def sanitize_filename(value)
    # get only the filename, not the whole path
    just_filename = value.gsub(/^.*(\\|\/)/, '')
    # NOTE: File.basename doesn't work right with Windows paths on Unix
    # INCORRECT: just_filename = File.basename(value.gsub('\\\\', '/')) 

    # Finally, replace all non alphanumeric, hyphens or periods with underscore
    @filename = just_filename.gsub(/[^\w\.\-]/,'_') 
  end
  
  # Returns an ASCII or hashed filename
  def self.disk_filename(filename)
    df = DateTime.now.strftime("%y%m%d%H%M%S") + "_"
    if filename =~ %r{^[a-zA-Z0-9_\.\-]*$}
      df << filename
    else
      df << Digest::MD5.hexdigest(filename)
      # keep the extension if any
      df << $1 if filename =~ %r{(\.[a-zA-Z0-9]+)$}
    end
    df
  end
end


# == Schema Information
#
# Table name: attachments
#
#  id             :integer         not null, primary key
#  container_id   :integer         default(0), not null
#  container_type :string(30)      default(""), not null
#  filename       :string(255)     default(""), not null
#  disk_filename  :string(255)     default(""), not null
#  filesize       :integer         default(0), not null
#  content_type   :string(255)     default("")
#  digest         :string(40)      default(""), not null
#  downloads      :integer         default(0), not null
#  author_id      :integer         default(0), not null
#  created_at     :datetime
#  description    :string(255)
#

