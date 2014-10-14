require 'spec_helper'

describe ReputationsController, '#destroy' do

  let(:reputation) { Factory.create(:reputation) }
  let(:valid_params) { { :id => reputation.id } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  it 'destroys the reputation' do
    delete(:destroy, valid_params)
    Reputation.find_by_id(reputation.id).should be_nil
  end

  context 'format html' do
    it 'redirects to reputations/index' do
      delete(:destroy, valid_params)
      response.should redirect_to(reputations_path)
    end
  end

  context 'format xml' do
    it 'renders status "OK"' do
      delete(:destroy, xml_params)
      response.status.should == '200 OK'
    end
  end

end
