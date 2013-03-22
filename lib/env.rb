require 'yaml'

module NotesMailCLI
  class Env
    class << self
      def load(config_file)
        new config_file
      end
    end

    attr_reader :notes_jar_location, :mail_server, :mail_file

    def initialize(config_file)
      config = YAML.load_file config_file
      @notes_jar_location = config.fetch("notes-jar-location")
      @mail_server = config.fetch("connection").fetch("mail_server")
      @mail_file = config.fetch("connection").fetch("mail_file")
    end
  end
end
