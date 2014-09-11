require 'spec_helper'

describe RetroRatingsController, '#new' do

  integrate_views

  it 'assigns @retro_rating' do
    get(:new)
    assigns(:retro_rating).should be_new_record
  end

  context 'format html' do
    it 'renders the new template' do
      get(:new)
      response.should render_template('retro_ratings/new')
      response.layout.should == 'layouts/gooey'
    end
  end

  context 'format xml' do
    it 'renders a new retro rating as xml' do
      get(:new, :format => 'xml')
      response.body.should == RetroRating.new.to_xml
    end
  end

end
