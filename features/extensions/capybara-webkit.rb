Capybara::Driver::Webkit::Browser.class_eval do
  @@pid = nil

  def initialize(options = {})
    @socket_class = options[:socket_class] || TCPSocket
    ensure_server
    connect
  end

  private

  def ensure_server; start_server unless server_running?; end
  def start_server
    server_path = File.expand_path("#{gem_path}/bin/webkit_server", __FILE__)
    @@pid = fork { exec(server_path) }
    at_exit { Process.kill("INT", @@pid) }
  end
  def gem_path; @gem_path ||= Gem.loaded_specs["capybara-webkit"].full_gem_path; end
  def server_running?; !@@pid.nil?; end
end
