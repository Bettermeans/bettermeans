require 'spec_helper'

describe RetroRatingsController, '#show' do

  integrate_views

  let(:retro_rating) { Factory.create(:retro_rating) }
  let(:valid_params) { { :id => retro_rating.id } }

  it 'assigns @retro_rating' do
    get(:show, valid_params)
    assigns(:retro_rating).should == retro_rating
  end

  context 'format html' do
    it 'renders the show template' do
      get(:show, valid_params)
      response.should render_template('retro_ratings/show')
      response.layout.should == 'layouts/gooey'
    end
  end

  context 'format xml' do
    it 'renders the retro rating as xml' do
      get(:show, valid_params.merge(:format => 'xml'))
      response.body.should == retro_rating.to_xml
    end
  end

end
