require "backticks/version"
require "backticks/cli"
require "backticks/command"
require "backticks/runner"

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
