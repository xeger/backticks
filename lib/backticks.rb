require_relative 'backticks/version'
require_relative 'backticks/cli'
require_relative 'backticks/command'
require_relative 'backticks/runner'
require_relative 'backticks/ext'

module Backticks
  # Run a command with default invocation options; return a Command object that
  # can be used to interact with the running process.
  #
  # @param [Array] sugar list of command words and options
  # @return [Backticks::Command] a running command
  # @see Backticks::Runner#run for a better description of sugar
  # @see Backticks::Runner for more control over process invocation
  def self.new(*sugar)
    Backticks::Runner.new.run(*sugar)
  end

  # Run a command with default invocation options; wait for to exit, then return
  # its output. Populate $? with the command's status before returning.
  #
  # @param [Array] sugar list of command words and options
  # @return [String] the command's output
  # @see Backticks::Runner#run for a better description of sugar
  # @see Backticks::Runner for more control over process invocation
  def self.run(*sugar)
    command = self.new(*sugar)
    command.join
    command.captured_output
  end

  # Run a command; return whether it succeeded or failed.
  #
  # @param [Array] sugar list of command words and options
  # @return [Boolean] true if the command succeeded; false otherwise
  # @see Backticks::Runner#run for a better description of sugar
  # @see Backticks::Runner for more control over process invocation
  def self.system(*sugar)
    command = self.new(*sugar)
    command.join
    $?.success?
  end
end
