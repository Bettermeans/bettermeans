require 'spec_helper'

describe SharesController, '#index' do

  let!(:share) { Factory.create(:share) }
  let(:project) { Factory.create(:project) }

  context 'format html' do
    it 'renders the "index" template' do
      get(:index)
      response.should render_template('shares/index')
    end

    it 'assigns @project when given a project_id' do
      get(:index, :project_id => project.id)
      assigns(:project).should == project
    end
  end

  context 'format xml' do
    it 'renders all shares as xml' do
      get(:index, :format => 'xml')
      response.body.should == [share].to_xml
    end
  end

end
