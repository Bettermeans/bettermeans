# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

module Redmine
  module MimeType

    MIME_TYPES = {
      'text/plain' => 'txt,tpl,properties,patch,diff,ini,readme,install,upgrade',
      'text/css' => 'css',
      'text/html' => 'html,htm,xhtml',
      'text/jsp' => 'jsp',
      'text/x-c' => 'c,cpp,cc,h,hh',
      'text/x-csharp' => 'cs',
      'text/x-java' => 'java',
      'text/x-javascript' => 'js',
      'text/x-html-template' => 'rhtml,html.erb',
      'text/x-perl' => 'pl,pm',
      'text/x-php' => 'php,php3,php4,php5',
      'text/x-python' => 'py',
      'text/x-ruby' => 'rb,rbw,ruby,rake,erb',
      'text/x-csh' => 'csh',
      'text/x-sh' => 'sh',
      'text/xml' => 'xml,xsd,mxml',
      'text/yaml' => 'yml,yaml',
      'image/gif' => 'gif',
      'image/jpeg' => 'jpg,jpeg,jpe',
      'image/png' => 'png',
      'image/tiff' => 'tiff,tif',
      'image/x-ms-bmp' => 'bmp',
      'image/x-xpixmap' => 'xpm',
      'application/pdf' => 'pdf',
      'application/zip' => 'zip',
      'application/x-gzip' => 'gz',
    }.freeze

    EXTENSIONS = MIME_TYPES.inject({}) do |map, (type, exts)|
      exts.split(',').each {|ext| map[ext.strip] = type}
      map
    end

    # returns mime type for name or nil if unknown
    def self.of(name) # spec_me cover_me heckle_me
      return nil unless name
      m = name.to_s.match(/(^|\.)([^\.]+)$/)
      EXTENSIONS[m[2].downcase] if m
    end

    # Returns the css class associated to
    # the mime type of name
    def self.css_class_of(name) # spec_me cover_me heckle_me
      mime = of(name)
      mime && mime.gsub('/', '-')
    end

    def self.main_mimetype_of(name) # spec_me cover_me heckle_me
      mimetype = of(name)
      mimetype.split('/').first if mimetype
    end

    # return true if mime-type for name is type/*
    # otherwise false
    def self.is_type?(type, name) # spec_me cover_me heckle_me
      main_mimetype = main_mimetype_of(name)
      type.to_s == main_mimetype
    end
  end
end
