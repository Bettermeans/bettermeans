require 'spec_helper'

describe RetroRatingsController, '#edit' do

  integrate_views

  let(:retro_rating) { Factory.create(:retro_rating) }
  let(:valid_params) { { :id => retro_rating.id } }

  it 'assigns @retro_rating' do
    get(:edit, valid_params)
    assigns(:retro_rating).should == retro_rating
  end

end
