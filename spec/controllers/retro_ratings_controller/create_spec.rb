require 'spec_helper'

describe RetroRatingsController, '#create' do

  let(:user) { Factory.create(:user) }
  let(:retro) { Factory.create(:retro) }

  let(:valid_params) do
    { :retro_ratings => {
        0 => { :retro_id => retro.id, :rater_id => user.id, :score => 59 },
        1 => { :retro_id => retro.id, :rater_id => user.id, :score => 23 },
    } }
  end
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  it 'assigns @retro_ratings' do
    post(:create, valid_params)
    retro_ratings = assigns(:retro_ratings)
    retro_ratings.length.should == 2
    retro_ratings.first.score.should == 59
    retro_ratings.last.score.should == 23
    retro_ratings.map(&:rater).uniq.should == [user]
    retro_ratings.map(&:retro).uniq.should == [retro]
  end

  it 'assigns @retro_id' do
    post(:create, valid_params)
    assigns(:retro_id).should == retro.id
  end

  it 'assigns @rater_id' do
    post(:create, valid_params)
    assigns(:rater_id).should == user.id
  end

  context 'if all retro ratings are valid' do
    it 'deletes all previous ratings for the given retro and user' do
      old_rating = Factory.create(:retro_rating, :retro => retro, :rater => user)
      post(:create, valid_params)
      RetroRating.find_by_id(old_rating.id).should be_nil
    end

    it 'saves all the new retro ratings' do
      lambda {
        post(:create, valid_params)
      }.should change(RetroRating, :count).by(2)
    end

    context 'format html' do
      it 'redirects to retro_ratings/index' do
        post(:create, valid_params)
        response.should redirect_to(retro_ratings_path)
      end
    end

    context 'format xml' do
      it 'renders the retro rating as xml' do
        post(:create, xml_params)
        response.body.should == assigns(:retro_ratings).to_xml
      end

      it 'renders created status' do
        post(:create, xml_params)
        response.status.should == '201 Created'
      end

      it 'renders the path to the retro rating' do
        post(:create, xml_params)
        response.location.should == retro_ratings_path
      end
    end
  end

  context 'if not all retro ratings are valid' do
    let(:bad_rating) do
      RetroRating.new(:retro_id => retro.id, :rater_id => user.id)
    end

    before(:each) do
      bad_rating.stub(:valid?).and_return(false)
      bad_rating.errors.add(:wat, 'an error')
      RetroRating.stub(:new).and_return(bad_rating)
    end

    context 'format html' do
      it 'renders the new template' do
        post(:create, valid_params)
        response.should render_template('retro_ratings/new')
      end
    end

    context 'format xml' do
      it 'renders the errors as xml' do
        post(:create, valid_params.merge(:format => 'xml'))
        response.body.should == bad_rating.errors.to_xml
      end

      it 'renders unproccessable entity status' do
        post(:create, valid_params.merge(:format => 'xml'))
        response.status.should == '422 Unprocessable Entity'
      end
    end
  end

end
