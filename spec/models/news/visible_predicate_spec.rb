require 'spec_helper'

describe News, '#visible?' do

  let(:author) { Factory.create(:user) }
  let(:project) { Factory.create(:project) }
  let(:news) { News.new(:author => author, :project => project) }

  context 'when a current user exists and has view permission' do
    it 'returns true' do
      author.stub(:allowed_to?).and_return true
      news.visible?(author).should be true
    end
  end

  context 'when no user does not have view permission' do
    it 'returns false' do
      author.stub(:allowed_to?).and_return false
      news.visible?(author).should be false
    end
  end

  context 'when no user is nil' do
    it 'returns false' do
      news.visible?(nil).should be false
    end
  end

end
