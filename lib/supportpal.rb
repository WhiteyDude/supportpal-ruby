require "supportpal/version"
require "httparty"

class SupportPal
  include HTTParty
  # Uncomment too debug output
  debug_output $stdout
  class Error < StandardError; end

  def initialize(options)
    # Make a class variable
    @options = options
    
    # Check to ensure required options exist
    raise Error, 'You must provide a base_uri option!' if ! @options['base_uri']
    self.class.base_uri @options['base_uri']

    # Default headers
    @auth = { username: @options['token'], password: '' }
    @http_options = { basic_auth: @auth }
    puts "HTTP Options: #{@http_options.inspect}"
  end

  def test
    puts "Base URI is #{self.class.base_uri}"
    res = self.class.get('/api/core/brand', @http_options)
  end
end
