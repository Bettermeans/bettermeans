require 'spec_helper'

describe RetroRatingsController, '#index' do

  let!(:retro_rating) { Factory.create(:retro_rating) }

  it 'assigns @retro_ratings' do
    get(:index)
    assigns(:retro_ratings).should == [retro_rating]
  end

  context 'format html' do
    it 'renders the index template' do
      get(:index)
      response.should render_template('retro_ratings/index')
      response.layout.should == 'layouts/gooey'
    end
  end

  context 'format xml' do
    it 'renders all retro ratings as xml' do
      get(:index, :format => 'xml')
      response.body.should == [retro_rating].to_xml
    end
  end

end
