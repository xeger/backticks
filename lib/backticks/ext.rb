module Backticks
  module Ext
    def `(str)
      Backticks.command(str)
    end
  end
end