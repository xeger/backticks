require 'spec_helper'

describe Backticks::CLI do
  describe Backticks::CLI::Getopt do
    describe "self.options" do
      it "converts hash arguments" do
        expect(Backticks::CLI::Getopt.options(:X => "V")).to eq(["-X", "V"])
      end
    end
  end
end
