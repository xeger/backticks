describe Backticks::Runner do
  let(:pid) { 123 }
  let(:waiter) { double('wait thread', pid:pid) }
  [:master, :slave, :reader, :writer].each do |fd|
    let(fd) { double(fd, close:true) }
  end

  before do
    # Use fake PTY/spawn to avoid MacOS resource exhaustion
    allow(PTY).to receive(:open).and_return([master, slave])
    allow(IO).to receive(:pipe).and_return([reader, writer])
    allow(subject).to receive(:spawn).and_return(pid)
  end

  describe '#run' do
    context 'with default cli' do
      it 'runs unbuffered' do
        subject.buffered = false
        expect(PTY).to receive(:open).exactly(3).times
        expect(IO).to receive(:pipe).never
        cmd = subject.run('ls', recursive:true, long:true)
        expect(cmd).to have_pid(pid)
      end

      it 'runs buffered' do
        subject.buffered = true
        expect(PTY).to receive(:open).never
        expect(IO).to receive(:pipe).exactly(3).times
        cmd = subject.run('ls', recursive:true, long:true)
        expect(cmd).to have_pid(pid)
      end

      it 'runs mixed' do
        expect(PTY).to receive(:open).twice
        expect(IO).to receive(:pipe).once
        subject.buffered = [:stdin, :stderr]
        cmd = subject.run('ls', recursive:true, long:true)
        expect(cmd).to have_pid(pid)
      end
    end
  end

  [:command].each do |deprecated|
    describe format('#%s',deprecated) do
      it 'does not exist' do
        pending('major version 1.0') if Backticks::VERSION < '1'
        expect(subject.respond_to?(deprecated)).to eq(false)
      end
    end
  end
end