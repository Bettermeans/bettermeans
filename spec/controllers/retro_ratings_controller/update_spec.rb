require 'spec_helper'

describe RetroRatingsController, '#update' do

  let(:retro_rating) { Factory.create(:retro_rating) }
  let(:valid_params) do
    { :id => retro_rating.id, :retro_rating => { :score => 52 } }
  end

  it 'assigns @retro_rating' do
    put(:update, valid_params)
    assigns(:retro_rating).should == retro_rating
    retro_rating.reload.score.should == 52
  end

  context 'if retro rating updates' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        put(:update, valid_params)
        flash[:success].should match(/successfully updated/i)
      end

      it 'redirects to retro_ratings/show' do
        put(:update, valid_params)
        response.should redirect_to(retro_rating)
      end
    end

    context 'format xml' do
      it 'renders status OK' do
        put(:update, valid_params.merge(:format => 'xml'))
        response.status.should == '200 OK'
        response.body.should be_blank
      end
    end
  end

  context 'if retro rating does not update' do
    before(:each) do
      retro_rating.stub(:valid?).and_return(false)
      retro_rating.errors.add(:wat, 'an error')
      RetroRating.stub(:find).and_return(retro_rating)
    end

    context 'format html' do
      it 'renders the edit template' do
        put(:update, valid_params)
        response.should render_template('retro_ratings/edit')
      end
    end

    context 'format xml' do
      it 'renders the errors as xml' do
        put(:update, valid_params.merge(:format => 'xml'))
        response.body.should == retro_rating.errors.to_xml
      end

      it 'renders status 422' do
        put(:update, valid_params.merge(:format => 'xml'))
        response.status.should == '422 Unprocessable Entity'
      end
    end
  end

end
