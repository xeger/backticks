$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'backticks'

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
