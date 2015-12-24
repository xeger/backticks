# Backticks

Backticks is an intuitive OOP wrapper for invoking command-line processes and
interacting with them. It uses PTYs

By default, processes that you invoke

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'backticks'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install backticks

## Usage

```ruby
require 'backticks'

# The easy way
output = Backticks.command('ls', R:true, '*.rb')
puts "Exit status #{$?.to_i}. Output:"
puts output

# The hard way; allows customization such as interactive mode, which proxies
# the child process's stdin, stdout and stderr to the parent process.
command = Backticks::Runner.new(interactive:true).command('ls', R:true, '*.rb')
command.join
puts "Exit status: #{command.status.to_i}. Output:"
puts command.captured_output
```

### Buffering

By default, Backticks allocates a pseudo-TTY for stdout and two Unix pipes for
stderr/stdin; this captures stdout in real-time, but stderr and
stdin are subject to unavoidable Unix pipe buffering.

To use pipes for all io streams, enable buffering when you construct your
Runner:

```ruby
Backticks::Runner.new(buffered:true)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xeger/backticks. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.
