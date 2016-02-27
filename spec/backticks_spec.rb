describe Backticks do
  it 'has a version number' do
    expect(Backticks::VERSION).not_to eq(nil)
  end

  describe '.new' do
    it 'returns a Command' do
      expect(subject.new('ls')).to be_a(Backticks::Command)
    end

    it 'accepts all-in-one commands' do
      expect(subject.new('ls -lR')).to succeed
    end

    it 'accepts one-word commands' do
      expect(subject.new('ls')).to succeed
    end

    it 'accepts multi-word commands' do
      expect(subject.new('ls', '-lR')).to succeed
    end

    it 'accepts sugared commands' do
      expect(subject.new('ls', l:true, R:true)).to succeed
    end
  end

  describe '.run' do
    it "returns the command's output" do
      expect(subject.run('echo hi').strip).to eq("hi")
    end
  end

  describe '.system' do
    it "returns the command's success status" do
      expect(subject.system('false')).to eq(false)
      expect(subject.system('true')).to eq(true)
    end
  end
end
