require 'pty'

module Backticks
  # An easy-to-use interface for invoking commands and capturing their output.
  # Instances of Runner can be interactive, which prints the command's output
  # to the terminal and also allows the user to interact with the command.
  # They can also be unbuffered, which uses a pseudo-tty to capture the
  # command's output with no delay or
  class Runner
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

    # If true, commands will be invoked with a pseudo-TTY for stdout in order
    # to capture output as it is generated instead of waiting for pipe buffers
    # to fill.
    #
    # @return [Boolean]
    attr_accessor :buffered

    # @return [#parameters] the CLI-translation object used by this runner
    attr_reader :cli

    # Create an instance of Runner.
    # @param [#parameters] cli object used to convert Ruby method parameters into command-line parameters
    def initialize(options={})
      options = {
        :buffered => false,
        :cli => Backticks::CLI::Getopt,
        :interactive => false,
      }.merge(options)

      @buffered = options[:buffered]
      @cli = options[:cli]
      @interactive = options[:interactive]
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
    # @param [Array] args list of command words and options
    #
    # @return [Command] the running command
    #
    # @example Run docker-compose with complex parameters
    #   command('docker-compose', {file: 'joe.yml'}, 'up', {d:true}, 'mysvc')
    def command(*args)
      argv = @cli.parameters(*args)

      if self.buffered
        run_buffered(argv)
      else
        run_unbuffered(argv)
      end
    end

    # Run a command. Use a pty to capture the unbuffered output.
    #
    # @param [Array] argv command to run; argv[0] is program name and the
    #   remaining elements are parameters and flags
    # @return [Command] the running command
    private
    def run_unbuffered(argv)
      stdout, stdout_w = PTY.open
      stdin_r, stdin = PTY.open
      stderr, stderr_w = PTY.open
      pid = spawn(*argv, in: stdin_r, out: stdout_w, err: stderr_w)
      stdin_r.close
      stdout_w.close
      stderr_w.close
      unless @interactive
        stdin.close
        stdin = nil
      end

      Command.new(pid, stdin, stdout, stderr)
    end

    # Run a command. Perform no translation or substitution. Use a pipe
    # to read the output, which may be buffered by the OS. Return the program's
    # exit status and stdout.
    #
    # @param [Array] argv command to run; argv[0] is program name and the
    #   remaining elements are command-line arguments.
    # @return [Command] the running command
    def run_buffered(argv)
      stdin, stdout, stderr, thr = Open3.popen3(*argv)
      unless @interactive
        stdin.close
        stdin = nil
      end

      Command.new(thr.pid, stdin, stdout, stderr)
    end
  end
end
