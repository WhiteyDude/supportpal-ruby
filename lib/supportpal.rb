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
      params['subject']                     = subject
      params['text']                        = message

      params['user']                        = @config[:ticket_user_id]
      params['user']                        = options[:operator_id] if options[:operator_id]
      params['user']                        = options[:user_id] if options[:user_id]

      params['department']                  = (options[:department]) ? options[:department] : @config[:ticket_department_id]
      params['status']                      = (options[:status]) ? options[:status] : @config[:ticket_status]
      params['priority']                    = (options[:priority]) ? options[:priority] : @config[:ticket_priority]

      params['internal']                    = options[:internal] if options[:internal]

      params['send_user_email']             = (options[:send_user_email]) ? options[:send_user_email] : @config[:ticket_send_user_email]
      params['send_operators_email']        = (options[:send_operators_email]) ? options[:send_operators_email] : @config[:ticket_send_operators_email]

      @http_options.merge!({ body: params })
      res = self.class.post('/api/ticket/ticket', @http_options)
      response = res.parsed_response
      if response['status'] == 'success' then
        return {
          :status                           => 'success',
        :ticket_id                          => response['data']['id']
        }
      else
        return {
          :status                           => 'failure',
          :message                          => response['message']
        }
      end
    end

    def add_ticket_note(ticket_id, message, options = {})
      params = {}
      params['text']                        = message

      params['user_id']                     = @config[:ticket_user_id]
      params['user_id']                     = options['operator_id'] if options['operator_id']
      params['user_id']                     = options['user_id'] if options['user_id']

      params['ticket_id']                   = ticket_id
      params['message_type']                = 1 # 1 = note, 0 = reply

      @http_options.merge!({ body: params })
      res = self.class.post("/api/ticket/message", @http_options)
      response = res.parsed_response
      if response['status'] == 'success' then
        return {
          :status                           => 'success',
          :message                          => response['message']
        }
      else
        return {
          :status                           => 'failure',
          :message                          => response['message']
        }
      end
    end

    def close_ticket_by_id(ticket_id)
      # Check if ticket_id is an integer
      @http_options.merge!({ body: { status: 2 } })
      res = self.class.put("/api/ticket/ticket/#{ticket_id}", @http_options)
      response = res.parsed_response
      if response['status'] == 'success' then
        return {
          :status                           => 'success',
          :message                          => response['message']
        }
      else
        return {
          :status                           => 'failure',
          :message                          => response['message']
        }
      end
    end

  end
end