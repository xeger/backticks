# Unit test of process runner; actual subprocess invocations are mocked out.
# @see command_spec.rb for functional tests of this class
describe Backticks::Runner do
  let(:pid) { 123 }
  [:master, :slave, :reader, :writer].each do |fd|
    let(fd) { double(fd, close:true) }
  end

  before do
    # Use fake PTY to avoid MacOS resource exhaustion
    allow(PTY).to receive(:open).and_return([master, slave])
    allow(IO).to receive(:pipe).and_return([reader, writer])
    allow(subject).to receive(:spawn).and_return(pid)
  end

  describe '#run' do
    context 'given chdir' do
      it 'spawns with new pwd' do
        subject.chdir='/tmp/banana'
        expect(subject).to receive(:spawn).with('ls', hash_including(chdir:'/tmp/banana'))
        cmd = subject.run('ls')
      end

      it 'defaults to PWD' do
        subject.chdir=nil
        expect(subject).to receive(:spawn).with('ls', hash_including(chdir:Dir.pwd))
        cmd = subject.run('ls')
      end
    end

    it 'works when unbuffered' do
      subject.buffered = false
      expect(PTY).to receive(:open).exactly(3).times
      expect(IO).to receive(:pipe).never
      cmd = subject.run('ls', recursive:true, long:true)
      expect(cmd).to have_pid(pid)
    end

    it 'works when buffered' do
      subject.interactive = false
      subject.buffered = true
      expect(PTY).to receive(:open).never
      expect(IO).to receive(:pipe).exactly(3).times
      cmd = subject.run('ls', recursive:true, long:true)
      expect(cmd).to have_pid(pid)
    end

    it 'works when partially buffered' do
      expect(PTY).to receive(:open).once
      expect(IO).to receive(:pipe).twice
      subject.buffered = [:stdin, :stderr]
      cmd = subject.run('ls', recursive:true, long:true)
      expect(cmd).to have_pid(pid)
    end

    it 'works when interactive' do
      expect(PTY).to receive(:open).twice
      expect(IO).to receive(:pipe).once
      subject.buffered = true
      subject.interactive = true
      cmd = subject.run('ls', recursive:true, long:true)
      expect(cmd).to have_pid(pid)
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