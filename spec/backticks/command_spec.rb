# Unit test of the running-command object. Doubles as a functional test
# for Runner and Command; actual subprocesses are invoked in some test cases.
describe Backticks::Command do
  let(:pid) { 123 }
  let(:stdin) { double('stdin') }
  let(:stdout) { double('stdout') }
  let(:stderr) { double('stderr') }
  subject { Backticks::Command.new(pid, stdin, stdout, stderr) }

  # Avoid unnecessary PTY allocation, but still allow some functional tests
  # (i.e. real processes are invoked).
  let(:runner) { Backticks::Runner.new(:buffered => true) }

  describe '#success?' do
    it 'returns true when command succeeded' do
      expect(runner.run('true').success?).to eq(true)
    end

    it 'returns false when command failed' do
      expect(runner.run('false').success?).to eq(false)
    end
  end

  describe '#tap' do
    subject { runner.run('echo the quick red fox jumped over the lazy brown dog') }

    it 'can discard output' do
      subject.tap { |stream, data| nil }
      subject.join
      expect(subject.captured_output).to eq('')
    end

    it 'can transform output' do
      subject.tap { |stream, data| data.reverse }
      subject.join
      expect(subject.captured_output.strip).to eq('god nworb yzal eht revo depmuj xof der kciuq eht')
    end

    it 'idempotently allows one block' do
      blk = lambda { |s, d| d.reverse }

      subject.tap(&blk)

      expect do
        subject.tap { |s, d| d * 2 }
      end.to raise_error(StandardError)
    end
  end

  describe '#join' do
    subject { runner.run('ls') }

    it 'is idempotent' do
      subject.join
      expect {subject.join}.not_to raise_error
      expect(subject).to succeed
    end

    context 'given a time limit' do
      before { allow(IO).to receive(:select).and_return([]) }

      it 'waits forever when limit is nil' do
        expect(IO).to receive(:select).with(
          anything, anything, anything,
          be_within(0.5).of(Backticks::Command::FOREVER)
        )
        subject.join
      end

      it 'returns early when limit is provided' do
        expect(IO).to receive(:select).with(
          anything, anything, anything,
          be_within(0.5).of(3)
        )
        subject.join(3)
      end
    end

    context 'given interactive is true' do
      let(:runner) { Backticks::Runner.new(:interactive => true) }
      subject { Backticks::Runner.new(:interactive => true).run('ls') }

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

  describe '#capture' do
    subject { runner.run('sh', '-c', 'sleep 1 ; echo hi') }

    it 'waits forever when limit is nil' do
      t0 = Time.now
      subject.capture
      t1 = Time.now
      expect(t1 - t0).to be_within(0.5).of(1)
    end

    it 'returns early when limit is present' do
      t0 = Time.now
      subject.capture(0.1)
      t1 = Time.now
      expect(t1 - t0).to be_within(0.05).of(0.1)
    end
  end

  it 'has attribute readers for captured I/O' do
    [:captured_input, :captured_output, :captured_error].each do |d|
      expect(subject).to be_a(Backticks::Command)
      expect(subject.respond_to?(d)).to eq(true)
    end
  end
end
