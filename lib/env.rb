module Env
  require 'yaml'

  attr_reader :mail_server,:mail_file

  def self.load(config_file)
    config = YAML.load_file config_file
    connection = config["connection"]
    @mail_server = connection["mail_server"]
    @mail_file = connection["mail_file"]
  end
end