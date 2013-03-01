require 'getoptlong'
require 'highline/import'


require_relative '../lib/menu'
require_relative '../lib/env'

include Env

class NotesMailCLI
  VERSION = '0.0.1'
  DEFAULT_CONFIG_FILE = 'config.yaml'

  def self.intro
    puts "=============="
    puts "NOTES MAIL CLI"
    puts "=============="
    puts
    puts "A quick and dirty notes mail client."
    puts
    puts "Current version: #{VERSION}"
    puts
  end

  def initialize
    @run_app = true
    @config_file = DEFAULT_CONFIG_FILE
  end

  def run
    check_options
    if @run_app
      Env::load @config_file
      Menu::Main.new
    end
  end

  private

  def check_options
    if ARGV.length == 0
      check_config DEFAULT_CONFIG_FILE
    else
      @opts = GetoptLong.new(
      ["--help",          "-h", GetoptLong::NO_ARGUMENT],
      ["--use-config",    "-u", GetoptLong::REQUIRED_ARGUMENT],
      ["--create-config", "-c", GetoptLong::OPTIONAL_ARGUMENT]
      )
      @opts.each do |opt, arg|
        case opt
        when "-h", "--help"
          show_help
        when "-c", "--create-config"
          arg.empty? ? create_config : create_config(arg)
        when "-u", "--use-config"
          use_config arg
        end
      end
    end
  end

  def show_help
    puts 'Available options: '
    puts '  -h      / --help                  Show this help.'
    puts '  -c FILE / --create-config FILE    Creates a custom config file. FILE is optional. Default is "config.yaml"'
    puts '  -u FILE / --use-config FILE       Uses a custom config file. FILE is required.'
    puts
    puts 'If no switch is set, the default is "-u config.yaml"'
    @run_app = false
  end

  def create_config(file = DEFAULT_CONFIG_FILE)
    config = {}
    mail_details = {}
    puts
    print "Mail server: "
    mail_details["mail_server"] = gets.chomp
    puts
    print "Mail file: "
    mail_details["mail_file"] = gets.chomp
    puts
    config["connection"] = mail_details
    File.open(file, "w") {|f| f.write(config.to_yaml) }
    puts "Created config file: #{file}"
    @run_app = false
  end

  def use_config(file)
    check_config file
    @config_file = file
  end

  def check_config(file)
    puts "Checking config file: #{file}"
    if File.exists?(file)
      config = YAML.load_file file
      if config.has_key? "connection"
        conn = config["connection"]
        unless conn.has_key?("mail_server") && conn.has_key?("mail_file")
          raise "Config file #{file} is not in a proper format."
          exit 1
        end
      else
        raise "Config file #{file} is not in a proper format."
        exit 1
      end
    else
      puts "Missing required config file: #{file}"
      puts
      if (file == DEFAULT_CONFIG_FILE)
        show_help
      end
    @run_app = false
    end
  end
end


begin
  NotesMailCLI.intro
  NotesMailCLI.new.run
rescue Exception=>e
  puts "Error: #{e.class}"
  puts "Message: #{e.message}"
  puts "Trace: #{e.backtrace}"
  exit 1
end