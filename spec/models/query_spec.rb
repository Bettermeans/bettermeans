require 'spec_helper'

describe Query do

  let(:query) { Query.new }

  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:user) }
  end

  describe '#valid?' do
    it { should validate_presence_of(:name) }
    it { should ensure_length_of(:name).is_at_most(255) }
  end

  describe 'after_initialize' do
  end

end
