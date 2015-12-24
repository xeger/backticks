require_relative 'backticks/version'
require_relative 'backticks/cli'
require_relative 'backticks/command'
require_relative 'backticks/runner'
require_relative 'backticks/ext'

module Backticks
  # Run a command.
  #
  # @return [Backticks::Command] a running command
  def self.new(*argv)
    Backticks::Runner.new.command(*argv)
  end

  # Run a command and return its stdout.
  #
  # @return [String] the command's output
  def self.command(*argv)
    command = self.new(*argv)
    command.join
    command.captured_output
  end
end
