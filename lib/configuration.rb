class Configuration
  def initialize
    env_vars = File.join(Dir.pwd, 'config/env_vars.rb')
    load(env_vars) if File.exists?(env_vars)
  end

  def config
    @config ||= load_config.freeze
  end

  private

  def config_file
    @config_file ||= File.expand_path('../../config/config.yml', __FILE__)
  end

  def load_config
    YAML.load_file(config_file)
  end
end
