desc 'Remove trailing whitespace and add newlines at end of files'
task :cleanup do

  filetypes = %w(
    builder
    conf
    css
    erb
    Gemfile
    haml
    html
    json
    rake
    rb
    rhtml
    rxml
    scss
    js
    txt
    xml
    yaml
    yml
  )

  paths = %w(
    app
    config
    curriculum/source
    db/migrate
    Gemfile
    lib
    modules
    public
    test
    spec
  )

  filetype_regexp = /\.(#{filetypes.join('|')})$/
  paths_regexp = /^(\.\/)?(#{paths.join('|')})/

  files = `find .`
  files.lines.each do |f|

    # Only examine specified file types and paths
    if f =~ filetype_regexp && f =~ paths_regexp

      # Add a linebreak to the end of the file if it doesn't have one
      if `tail -c1 #{f}` != "\n"
        puts "adding line break to #{f}"
        `echo >> #{f}`
      end

      # Remove trailing whitespace if it exists
      if system("grep -q '[[:blank:]]$' #{f}")
        puts "removing trailing spaces from #{f}"
        # sed command works differently on Mac and Linux
        if `uname` =~ /Darwin/
          `sed -i "" -e $'s/[ \t]*$//g' #{f}`
        elsif `uname` =~ /Linux/
          `sed -i -e 's/[ \t]*$//g' #{f}`
        end
      end
    end
  end

end
