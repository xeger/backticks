module Backticks
  module Ext
    def `(cmd)
      Backticks.run(cmd)
    end
  end
end
