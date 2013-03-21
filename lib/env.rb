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
      @notes_jar_location = config["notes-jar-location"]
      connection = config["connection"]
      @mail_server = connection["mail_server"]
      @mail_file = connection["mail_file"]
    end
  end
end
