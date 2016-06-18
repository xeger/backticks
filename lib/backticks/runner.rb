require 'pty'
require 'open3'

module Backticks
  # An easy-to-use interface for invoking commands and capturing their output.
  # Instances of Runner can be interactive, which prints the command's output
  # to the terminal and also allows the user to interact with the command.
  # By default commands are unbuffered, using a pseudoterminal to capture
  # the output with no delay.
  class Runner
    # Default streams to buffer if someone calls bufferered= with Boolean.
    BUFFERED = [:stdin, :stdout, :stderr].freeze

    # If true, commands will have their stdio streams tied to the parent
    # process so the user can view their output and send input to them.
    # Commands' output is still captured normally when they are interactive.
    #
    # Note that interactivity doesn't work very well with unbuffered commands;
    # we use pipes to connect to the command's stdio, and the OS forcibly
    # buffers pipe I/O. If you want to send some input to your command, you
    # may need to send a LOT of input before it receives any; the same problem
    # applies to reading your command's output. If you set interactive to
    # true, you usually want to set buffered to false!
    #
    # @return [Boolean]
    attr_accessor :interactive

    # List of I/O streams that should be captured using a pipe instead of
    # a pseudoterminal.
    #
    # This may be a Boolean, or it may be an Array of stream names from the
    # set [:stdin, stdout, stderr].
    #
    # @return [Array] list of symbolic stream names
    attr_reader :buffered

    # @return [#parameters] the CLI-translation object used by this runner
    attr_reader :cli

    # Create an instance of Runner.
    # @option [#include?,Boolean] buffered list of names; true/false for all/none
    # @option [#parameters] cli command-line parameter translator
    # @option [Boolean] interactive true to tie parent stdout/stdin to child
    #
    # @example buffer stdout
    #   Runner.new(buffered:[:stdout])
    def initialize(options={})
      options = {
        :buffered => false,
        :cli => Backticks::CLI::Getopt,
        :interactive => false,
      }.merge(options)

      @cli = options[:cli]
      self.buffered = options[:buffered]
      self.interactive = options[:interactive]
    end

    # @param [Array,Boolean] buffered list of symbolic stream names; true/false for all/none
    def buffered=(b)
      @buffered = case b
      when true then BUFFERED
      when false, nil then []
      else
        b
      end
    end

    # @deprecated
    def command(*sugar)
      warn 'Backticks::Runner#command is deprecated; please call #run instead'
      run(*sugar)
    end

    # Run a command whose parameters are expressed using some Rubyish sugar.
    # This method accepts an arbitrary number of positional parameters; each
    # parameter can be a Hash, an array, or a simple Object. Arrays and simple
    # objects are appended to argv as words of the command; Hashes are
    # translated to command-line options and then appended to argv.
    #
    # Hashes are processed by @cli, defaulting to Backticks::CLI::Getopt and
    # easily overridden by passing the `cli` option to #initialize.
    #
    # @see Backticks::CLI::Getopt for option-Hash format information
    #
    # @param [Array] sugar list of command words and options
    #
    # @return [Command] the running command
    #
    # @example Run docker-compose with complex parameters
    #   run('docker-compose', {file: 'joe.yml'}, 'up', {d:true}, 'mysvc')
    def run(*sugar)
      run_without_sugar(@cli.parameters(*sugar))
    end

    # Run a command whose argv is specified in the same manner as Kernel#exec,
    # with no Rubyish sugar.
    #
    # @param [Array] argv command to run; argv[0] is program name and the
    #   remaining elements are parameters and flags
    # @return [Command] the running command
    def run_without_sugar(argv)
      stdin_r, stdin = if buffered.include?(:stdin) && !interactive
        IO.pipe
      else
        PTY.open
      end
      stdout, stdout_w = if buffered.include?(:stdout) && !interactive
        IO.pipe
      else
        PTY.open
      end
      stderr, stderr_w = if buffered.include?(:stderr)
        IO.pipe
      else
        PTY.open
      end

      pid = spawn(*argv, in: stdin_r, out: stdout_w, err: stderr_w)
      stdin_r.close
      stdout_w.close
      stderr_w.close
      unless interactive
        stdin.close
        stdin = nil
      end

      Command.new(pid, stdin, stdout, stderr)
    end
  end
end
