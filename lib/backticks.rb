require_relative 'backticks/version'
require_relative 'backticks/cli'
require_relative 'backticks/command'
require_relative 'backticks/runner'
require_relative 'backticks/ext'

module Backticks
  # Run a command; return a Command object that can be used to interact with
  # the running process.
  #
  # @param [String] cmd
  # @return [Backticks::Command] a running command
  def self.new(cmd)
    Backticks::Runner.new.command(cmd)
  end

  # Run a command; return its stdout.
  #
  # @param [String] cmd
  # @return [String] the command's output
  def self.run(cmd)
    command = self.new(*cmd)
    command.join
    command.captured_output
  end

  # Run a command; return its success or failure.
  #
  # @param [String] cmd
  # @return [Boolean] true if the command succeeded; false otherwise
  def self.system(*cmd)
    command = self.new(*cmd)
    command.join
    $?.success?
  end
end
