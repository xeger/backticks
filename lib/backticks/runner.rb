begin
  require 'pty'
rescue LoadError
  # for Windows support, tolerate a missing PTY module
end

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
    # Note: if you set `interactive` to true, then stdin and stdout will be
    # unbuffered regardless of how you have set `buffered`!
    #
    # @return [Boolean]
    attr_accessor :interactive

    # List of I/O streams that should be captured using a pipe instead of
    # a pseudoterminal.
    #
    # When read, this attribute is always an Array of stream names from the
    # set `[:stdin, :stdout, :stderr]`.
    #
    # **Note**: if you set `interactive` to true, then stdin and stdout are
    # unbuffered regardless of how you have set `buffered`!
    #
    # @return [Array] list of symbolic stream names
    attr_reader :buffered

    # @return [String,nil] PWD for new child processes, default is Dir.pwd
    attr_accessor :chdir

    # @return [#parameters] the CLI-translation object used by this runner
    attr_reader :cli

    # Create an instance of Runner.
    #
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
      @chdir = nil
      self.buffered = options[:buffered]
      self.interactive = options[:interactive]
    end

    # Control which streams are buffered (i.e. use a pipe) and which are
    # unbuffered (i.e. use a pseudo-TTY).
    #
    # If you pass a Boolean argument, it is converted to an Array; therefore,
    # the reader for this attribute always returns a list even if you wrote
    # a boolean value.
    #
    # @param [Array,Boolean] buffered list of symbolic stream names; true/false for all/none
    def buffered=(b)
      @buffered = case b
      when true then BUFFERED
      when false, nil then []
      else
        b
      end
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
      nopty = !defined?(PTY)

      stdin_r, stdin = if nopty || (buffered.include?(:stdin) && !interactive)
        IO.pipe
      else
        PTY.open
      end

      stdout, stdout_w = if nopty || (buffered.include?(:stdout) && !interactive)
        IO.pipe
      else
        PTY.open
      end

      stderr, stderr_w = if nopty || buffered.include?(:stderr)
        IO.pipe
      else
        PTY.open
      end

      dir = @chdir || Dir.pwd
      pid = spawn(*argv, in: stdin_r, out: stdout_w, err: stderr_w, chdir: dir)
      stdin_r.close
      stdout_w.close
      stderr_w.close
      unless interactive
        stdin.close
        stdin = nil
      end

      Command.new(pid, stdin, stdout, stderr, interactive:interactive)
    end
  end
end
