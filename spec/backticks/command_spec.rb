describe Backticks::Command do
  describe '#join' do
    subject { Backticks.new('ls') }

    it 'is idempotent' do
      subject.join
      expect {subject.join}.not_to raise_error
      expect(subject).to succeed
    end

    context 'interactive' do
      subject { Backticks::Runner.new(:interactive => true).command('ls') }

      it 'gracefully handles empty STDIN' do
        allow(IO).to receive(:select).and_return([[STDIN], nil, nil])
        allow(STDIN).to receive(:readpartial).and_raise("Boom!")

        expect { subject.join }.not_to raise_error
      end

      it 'gracefully handles closed STDIN' do
        allow(IO).to receive(:select).and_return([[STDIN], nil, nil])
        allow(STDIN).to receive(:readpartial).and_return(nil)

        expect { subject.join }.not_to raise_error
      end
    end
  end

  [:captured_stdin, :captured_stdout, :captured_stderr].each do |deprecated|
    describe format('#%s',deprecated) do
      it 'does not exist' do
        pending('major version 1.0') if Backticks::VERSION < '1'
        expect(subject.respond_to?(deprecated)).to eq(false)
      end
    end
  end
end
