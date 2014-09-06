require 'spec_helper'

describe ActivityStreamsController, '#index' do

  integrate_views

  let(:project) { Factory.create(:project) }
  let(:user) { Factory.create(:user) }
  let(:valid_params) do
    {
      :user_id => user.id,
      :project_id => project.id,
      :with_subprojects => 'boo',
      :limit => 'loo',
    }
  end

  context 'when params[:refresh]' do
    it 'sets up fancy box' do
      get(:index, valid_params.merge(:refresh => 'poo'))
      response.body.should include('arm_fancybox')
    end
  end

  context 'when not params[:refresh]' do
    it 'sets up fancy box' do
      get(:index, valid_params)
      response.body.should include('arm_fancybox')
    end
  end

end
