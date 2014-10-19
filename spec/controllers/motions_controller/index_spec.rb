require 'spec_helper'

describe MotionsController, '#index' do

  let!(:motion) { Factory.create(:motion, :project => project) }
  let(:project) { Factory.create(:project) }
  let(:user) { Factory.create(:user) }
  let(:valid_params) { { :project_id => project.id } }

  before(:each) { login_as(user) }

  context 'format html' do
    it 'renders the "index" template' do
      get(:index, valid_params)
      response.should render_template('motions/index')
    end
  end

  context 'format xml' do
    it 'renders all motions as xml' do
      get(:index, valid_params.merge(:format => 'xml'))
      response.body.should == [motion.reload].to_xml
    end
  end

end
