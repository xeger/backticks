describe Backticks::Command do
  describe '#join' do
    subject { Backticks.new('ls') }

    it 'is idempotent' do
      subject.join
      expect {subject.join}.not_to raise_error
      expect(subject).to succeed
    end
  end
end
