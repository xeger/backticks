require 'pry'

require 'coveralls'
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'backticks'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  RSpec::Expectations.configuration.on_potential_false_positives = :raise
end

# Expect a Backticks::Command to succeed.
RSpec::Matchers.define :succeed do
  match do |actual|
    actual = actual.join if actual.respond_to?(:join)
    expect(actual.status).to be_success
  end
end

# Expect a Backticks::Command to fail.
RSpec::Matchers.define :fail do
  match do |actual|
    actual = actual.join if actual.respond_to?(:join)
    expect(actual.status).not_to be_success
  end
end

# Expect a Backticks::Command to have a certain pid
RSpec::Matchers.define :have_pid do |pid|
  match do |actual|
    expect(actual).to respond_to(:pid)
    expect(actual.pid).to equal(pid)
  end
end
