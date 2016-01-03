# Backticks

Backticks is an intuitive OOP wrapper for invoking command-line processes and
interacting with them. It improves on Ruby's built-in invocation methods in a
few ways:
  - Uses [pseudoterminals](https://en.wikipedia.org/wiki/Pseudoterminal) for unbuffered I/O
  - Captures input as well as output
  - Intuitive API that accepts CLI parameters as Ruby positional and keyword args

If you want to write a record/playback application for the terminal, or write
functional tests that verify your program's output in real time, Backticks is
exactly what you've been looking for!

For an example of the intuitive API, let's consider how we list a bunch of
files or search for some text with Backticks:

```ruby
# invokes "ls -l -R"
Backticks.run 'ls', l:true, R:true

# invokes "grep -H --context=2 --regexp=needle haystack.txt"
Backticks.run 'grep', {H:true, context:2, regexp:'needle'}, 'haystack.txt'
```

Notice how running commands feels like a plain old Ruby method call.

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

# The lazy way; provides no CLI sugar, but benefits from unbuffered output,
# and allows you to override Ruby's built-in backticks method.
shell = Object.new ; shell.extend(Backticks::Ext)
shell.instance_eval do
  puts `ls -l`
  raise 'Oh no!' unless $?.success?
end
# The just-as-lazy but less-magical way.
Backticks.system('ls -l') || raise('Oh no!')

# The easy way. Uses default options; returns the command's output as a String.
output = Backticks.run('ls', R:true, '*.rb')
puts "Exit status #{$?.to_i}. Output:"
puts output

# The hard way. Allows customized behavior; returns a Command object that
# allows you to interact with the running command.
command = Backticks::Runner.new(interactive:true).command('ls', R:true, '*.rb')
command.join
puts "Exit status: #{command.status.to_i}. Output:"
puts command.captured_output
```

### Buffering

By default, Backticks allocates a pseudo-TTY for stdin/stdout and a Unix pipe
for stderr; this captures the program's output and the user's input in realtime,
but stderr is buffered according to the whim of the kernel's pipe subsystem.

To use pipes for all I/O streams, enable buffering on the Runner:

```ruby
# at initialize-time
r = Backticks::Runner.new(buffered:true)

# or later on
r.buffered = false
```

### Interactivity

If you set `interactive:true` on the Runner, the console of the calling (Ruby)
process is "tied" to the child's I/O streams, allowing the user to interact
with the child process even as its input and output are captured for later use.

If the child process will use raw input, you need to set the parent's console
accordingly:

```ruby
require 'io/console'
# In IRB, call raw! on same line as command; IRB prompt uses raw I/O
STDOUT.raw! ; Backticks::Runner.new(interactive:true).command('vi').join
```

### Literally Overriding Ruby's Backticks

It's a terrible idea, but you can use this gem to change the behavior of
backticks system-wide by mixing it into Kernel.

```ruby
require 'backticks'
include Backticks::Ext
`echo Ruby lets me shoot myself in the foot`
```

If you do this, I will hunt you down and scoff at you. You have been warned!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xeger/backticks. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.
