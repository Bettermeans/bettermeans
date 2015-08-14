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

  context 'when the query is invalid' do
    before(:each) { query.update_attribute(:name, '') }

    it 'renders "issues/index"' do
      get(:index, :query_id => query.id)
      response.should render_template('issues/index')
    end

    it 'renders the gooey layout' do
      get(:index, :query_id => query.id)
      response.layout.should == 'layouts/gooey'
    end

    it 'renders without a layout when the request is xhr' do
      xhr(:get, :index, :query_id => query.id)
      response.layout.should be_nil
    end
  end

  it 'renders a 404 when query is not found' do
    get(:index, :query_id => 52000)
    response.status.should == '404 Not Found'
  end

end
