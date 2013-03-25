require 'getoptlong'
require 'highline/import'
require_relative '../lib/menu'
require_relative '../lib/env'

module NotesMailCLI
  VERSION = '0.0.1'
  DEFAULT_CONFIG_FILE = 'config.yaml'

  class << self
    def intro
      puts "=============="
      puts "NOTES MAIL CLI"
      puts "=============="
      puts
      puts "A quick and dirty notes mail client."
      puts
      puts "Current version: #{VERSION}"
      puts
    end
  end

  class Base
    def initialize
      @run_app = true
      @config_file = DEFAULT_CONFIG_FILE
    end

    def run
      @extra_opts = {}
      check_options
      if @run_app
        env = Env.load @config_file
        env.set @extra_opts
        Menu::Main.new env
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
        ["--create-config", "-c", GetoptLong::OPTIONAL_ARGUMENT],
        ["--password",      "-p", GetoptLong::REQUIRED_ARGUMENT]
        )
        @opts.each do |opt, arg|
          case opt
          when "-h", "--help"
            show_help
          when "-c", "--create-config"
            arg.empty? ? create_config : create_config(arg)
          when "-u", "--use-config"
            use_config arg
          when "-p", "--password"
            set_password arg
          end
        end
      end
    end

    def show_help
      puts 'Available options: '
      puts '  -h      / --help                  Show this help.'
      puts '  -c FILE / --create-config FILE    Creates a custom config file. FILE is optional. Default is "config.yaml"'
      puts '  -u FILE / --use-config FILE       Uses a custom config file.'
      puts '  -p PASSWORD                       Sets notes password. Will be asked later if not provided.'
      puts
      puts 'If no switch is set, the default is "-u config.yaml"'
      @run_app = false
    end

    def create_config(file = DEFAULT_CONFIG_FILE)
      config = {}
      mail_details = {}
      puts
      mail_details["mail_server"] = ask("Mail server: ") {|input| input.echo = true}
      puts
      mail_details["mail_file"] = ask("Mail file: ") {|input| input.echo = true}
      puts
      notes_jar_location = ask("Full path to Notes.jar: ") {|input| input.echo = true}
      config["connection"] = mail_details
      config["notes-jar-location"] = notes_jar_location
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

    def set_password(pwd)
      @extra_opts.merge!({:password => pwd})
    end
  end
end

begin
  NotesMailCLI::intro
  NotesMailCLI::Base.new.run
rescue Exception=>e
  puts "Error: #{e.class}"
  puts "Message: #{e.message}"
  puts "Trace: #{e.backtrace}"
  exit 1
end
