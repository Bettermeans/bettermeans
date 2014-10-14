require 'spec_helper'

describe RetroRatingsController, '#destroy' do

  let(:retro_rating) { Factory.create(:retro_rating) }
  let(:valid_params) { { :id => retro_rating.id } }

  it 'destroys the retro rating' do
    delete(:destroy, valid_params)
    RetroRating.find_by_id(retro_rating.id).should be_nil
  end

  context 'format html' do
    it 'redirects to retro_ratings/index' do
      delete(:destroy, valid_params)
      response.should redirect_to(retro_ratings_path)
    end
  end

  context 'format xml' do
    it 'renders status OK' do
      delete(:destroy, valid_params.merge(:format => 'xml'))
      response.body.should be_blank
      response.status.should == '200 OK'
    end
  end

end
