module SupportPal
  class Configure
    # Concept from https://stackoverflow.com/a/10112179

    def default_config
      @config = {
        :ticket_status                  => 1, # Open
        :ticket_priority                => 1, # Low
        :ticket_user_id                 => nil, # Operator or user
        :ticket_department_id           => nil,
        :ticket_send_user_email         => false, # Send an email to the user who opens the ticket when ticket opens
        :ticket_send_operators_email    => false, # Send an email to all operators when ticket opens
        :auth_token                     => nil, # SupportPal token
      }
    end  

    def configure(opts = {})
      opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
    end

    def configure_with(path_to_yaml_file)
      begin
        config = YAML::load(IO.read(path_to_yaml_file))
      rescue Errno::ENOENT
        puts "YAML configuration file couldn't be found. Using defaults."; return
      rescue Psych::SyntaxError
        puts "YAML configuration file contains invalid syntax. Using defaults."; return
      end
      configure(config)
    end

    def config
      @config
    end

    def initialize(config = nil)
      default_config
      @valid_config_keys = @config.keys
      if config.class == Hash then
        configure(config)
      elsif config.class == String then
        configure_with(config)
      end
    end
  end
end