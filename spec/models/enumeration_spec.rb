require 'spec_helper'

describe Enumeration do

  let(:enumeration) { Enumeration.new }

  describe 'associations' do
    it { should belong_to(:project) }
  end

  describe '#valid?' do
    it { should validate_presence_of(:name) }
  end


  describe '#option_name' do
    it 'returns nil' do
      enumeration.option_name.should be_nil
    end
  end

end
