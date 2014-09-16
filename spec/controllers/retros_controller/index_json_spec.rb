require 'spec_helper'

describe RetrosController, '#index_json' do

  integrate_views

  let!(:retro) { Factory.create(:retro, :project => project) }
  let(:project) { Factory.create(:project) }
  let(:params) { { :project_id => project.id } }

  it 'renders json for retros related to the given project' do
    get(:index_json, params)
    response.body.should == [retro].to_json
  end

end
