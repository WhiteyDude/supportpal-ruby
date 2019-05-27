require "supportpal/version"
require 'supportpal/config'
require "httparty"
require 'yaml'

module SupportPal
  # Errors
  class Error < StandardError; end

  class Session
    include HTTParty
    # Uncomment to debug output
    #debug_output $stdout

    def initialize(options)
      # Make a class variable
      @options = options

      # Load config
      if @options['config'] then # Can be hash with values, or path to yaml
        config = SupportPal::Configure.new(@options['config'])
      else
        config = SupportPal::Configure.new
      end
      @config = config.config
      puts @config.inspect
        
      # Check to ensure required options exist
      raise Error, 'You must provide a base_uri option!' if ! @options['base_uri']
      self.class.base_uri @options['base_uri']

      raise Error, 'You must provide an auth token in config!' if ! @config[:auth_token]

      # Default headers
      @auth = { username: @config[:auth_token], password: 'X' }
      @http_options = { basic_auth: @auth }
    end

    def test
      puts "Base URI is #{self.class.base_uri}"
      res = self.class.get('/api/selfservice/type', @http_options)
    end

    def open_new_ticket(subject, message, options = {})
      params = {}
      params['subject']           = subject
      params['text']              = message

      params['user']              = @config[:ticket_user_id]
      params['user']              = options['operator_id'] if options['operator_id']
      params['user']              = options['user_id'] if options['user_id']

      params['department']        = (options['department']) ? options['department'] : @config[:ticket_department_id]
      params['status']            = (options['status']) ? options['status'] : @config[:ticket_status]
      params['priority']          = (options['priority']) ? options['priority'] : @config[:ticket_priority]

      @http_options.merge!({ body: params })
      puts @http_options.inspect
      res = self.class.post('/api/ticket/ticket', @http_options)
      puts res.inspect
    end
  end
end