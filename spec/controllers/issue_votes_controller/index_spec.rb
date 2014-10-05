require 'spec_helper'

describe IssueVotesController, '#index' do

  integrate_views

  let!(:issue_vote) { Factory.create(:issue_vote) }

  context 'format html' do
    it 'renders the index template' do
      get(:index)
      response.should render_template('issue_votes/index')
    end
  end

  context 'format xml' do
    it 'renders all of the issue votes as xml' do
      get(:index, :format => 'xml')
      response.body.should == [issue_vote].to_xml
    end
  end

end
