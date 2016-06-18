# Introduction

Backticks is a powerful, intuitive OOP wrapper for invoking command-line processes and
interacting with them.

![Build Status](https://travis-ci.org/xeger/backticks.svg) [![Coverage Status](https://coveralls.io/repos/xeger/backticks/badge.svg?branch=master&service=github)](https://coveralls.io/github/xeger/backticks?branch=master)

"Powerful" comes from features that make Backticks especially well suited for time-sensitive
or record/playback applications:
  - Uses [pseudoterminals](https://en.wikipedia.org/wiki/Pseudoterminal) for realtime stdout/stdin
  - Captures input as well as output
  - Separates stdout from stderr

"Intuitive" comes from a DSL that lets you provide command-line arguments as if they were
Ruby method arguments:

```
Backticks.run 'ls', R:true, ignore_backups:true, hide:'.git'
Backticks.run 'cp' {f:true}, '*.rb', '/mnt/awesome'
```

If you want to write a record/playback application for the terminal, or write
functional tests that verify your program's output in real time, Backticks is
exactly what you've been looking for!

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
command = Backticks::Runner.new(interactive:true).run('ls', R:true, '*.rb')
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
STDOUT.raw! ; Backticks::Runner.new(interactive:true).run('vi').join
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

## Security

Backticks avoids using your OS shell, which helps prevent security bugs.
This also means that you can't pass strings such as "$HOME" to commands;
Backticks does not perform shell substitution. Pass ENV['HOME'] instead.

Be careful about the commands you pass to Backticks! Never run commands that
you read from an untrusted source, e.g. the network.

In the future, Backticks may integrate with Ruby's $SAFE level to provide smart
escaping and shell safety.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xeger/backticks. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.
