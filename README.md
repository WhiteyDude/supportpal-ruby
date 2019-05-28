# supportpal-ruby

This gem provides direct calls to the SupportPal REST APIs.

Current functions:

* Open a new ticket
* Add a note to a ticket (by ID)
* Close a ticket (by ID)

Other features may be added later as needed by me, however pull requests are always welcomne.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'supportpal-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install supportpal-ruby

## Usage

Basic example:

```ruby
require 'supportpal'

cwd = File.expand_path('../', __FILE__)

supportpal = SupportPal::Session.new({
  'base_uri'      => 'https://supportpal.local',
  'config'        => "#{cwd}/config.yml"
})
puts "Loaded SupportPal API version #{SupportPal::VERSION}"

ticket = supportpal.open_new_ticket(
  "Ticket subject",
  "This is a <strong>Ticket message!</strong>"
)

if ticket[:status] == 'success' then
    note = supportpal.add_ticket_note(ticket[:ticket_id], 'This is a test note')
    supportpal.close_ticket_by_id(ticket[:ticket_id])
else
    puts "Error opening new ticket - #{ticket[:message]}"
end
```

```yaml
ticket_user_id: 5
ticket_department_id: 3
auth_token: 2YpXPZ9BDYo6S9Unp5uQ4FH4q
```

`config` can be passed as path to yaml file, hash, or left blank for default options to be used.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/WhiteyDude/supportpal-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
