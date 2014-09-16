require 'spec_helper'

describe RetrosController, '#dashdata' do

  integrate_views

  let(:retro) { Factory.create(:retro) }
  let!(:issue) { Factory.create(:issue, :retro => retro) }
  let(:project) { Factory.create(:project) }
  let(:params) { { :id => retro.id, :project_id => project.id } }

  it 'returns json of issues related for the given retro' do
    get(:dashdata, params)
    issue_data = JSON.parse(response.body).first
    JSON.parse(issue.to_json).each do |key, value|
      issue_data[key].should == value
    end
  end

end
