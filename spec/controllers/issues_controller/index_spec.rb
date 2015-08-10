require 'spec_helper'

describe IssuesController, '#index' do

  let(:query) { Factory.create(:query) }

  it 'sets the sort default to the query sort criteria when present' do
    query.update_attributes!(:sort_criteria => ['foo'])
    get(:index, :query_id => query.id)
    assigns(:sort_default).should == [['foo', 'asc']]
  end

  it 'sets the sort default to id descending when query sort is not present' do
    get(:index, :query_id => query.id)
    assigns(:sort_default).should == [['id', 'desc']]
  end

end
