require 'spec_helper'

describe RetrosController, '#index' do

  let!(:retro) { Factory.create(:retro) }
  let(:project) { Factory.create(:project) }
  let(:params) { { :project_id => project.id } }

  it 'sets all retros' do
    get(:index, params)
    assigns(:retros).should == [retro]
  end

  it 'renders html format' do
    get(:index, params)
    response.should render_template('retros/index')
  end

  it 'renders xml format' do
    get(:index, params.merge(:format => 'xml'))
    response.body.should == [retro].to_xml
  end

end
