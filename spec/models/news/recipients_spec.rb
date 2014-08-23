require 'spec_helper'

describe News, '#recipients' do

  let(:author) { Factory.create(:user) }
  let(:project) { Factory.create(:project) }
  let(:news) { News.new(:author => author, :project => project) }

  it 'returns emails of users to be notified of news' do
    fake_user = mock(:pref => {}, :mail => 'bob@pop.com', :allowed_to? => true)
    project.stub(:notified_users).and_return([fake_user])
    news.recipients.should == ['bob@pop.com']
  end

end
