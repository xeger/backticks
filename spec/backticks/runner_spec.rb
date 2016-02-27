describe Backticks::Runner do
  describe '#command' do
    it 'does not exist' do
      pending('major version 1.0')
      expect(subject.respond_to?(:command)).to eq(false)
    end
  end
end