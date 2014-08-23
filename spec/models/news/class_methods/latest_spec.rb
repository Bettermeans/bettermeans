require 'spec_helper'

describe News, '.latest' do

  let(:author) { Factory.create(:user) }
  let(:project) { Factory.create(:project) }
  let(:news) { News.new(:author => author, :project => project, :title => "title", :description => 'description') }

  it 'returns latest news for projects visible by user' do
    news.save!
    Project.stub(:allowed_to_condition).and_return('')
    News.latest.should == [news]
  end

end
