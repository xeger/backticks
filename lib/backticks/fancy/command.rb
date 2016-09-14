module Backticks::Fancy
  class Command < ::Backticks::Command
    def initialize(pid, stdin, stdout, stderr, interactive:false)
      require 'curses'
      super
      Curses.init_screen
      @window = Curses::Window.new(Curses.lines - 4, Curses.width, 2, 0)
    end

    def join(limit=Backticks::FOREVER)
    ensure
      @window.close
      Curses.close_screen
    end
  end
end