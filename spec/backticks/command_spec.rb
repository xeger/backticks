# Unit test of the running-command object. Doubles as a functional test
# for the runner (actual subprocesses are invoked).
describe Backticks::Command do
  let(:pid) { 123 }
  let(:stdin) { double('stdin') }
  let(:stdout) { double('stdout') }
  let(:stderr) { double('stderr') }
  subject { Backticks::Command.new(pid, stdin, stdout, stderr) }

  # Avoid unnecessary PTY allocation, but still allow some functional tests
  # (i.e. real processes are invoked).
  let(:runner) { Backticks::Runner.new(:buffered => true) }

  describe '#join' do
    subject { runner.run('ls') }

    it 'is idempotent' do
      subject.join
      expect {subject.join}.not_to raise_error
      expect(subject).to succeed
    end

    context 'interactive' do
      let(:runner) { Backticks::Runner.new(:interactive => true) }
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

  context 'deprecated methods' do
    [:captured_input, :captured_output, :captured_error].each do |d|
      describe format('#%s',d) do
        it 'does not exist' do
          pending('major version 1.0') if Backticks::VERSION < '1'
          expect(subject).to be_a(Backticks::Command)
          expect(subject.respond_to?(d)).to eq(false)
        end
      end
    end
  end
end
