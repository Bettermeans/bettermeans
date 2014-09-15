require 'spec_helper'

describe SharesController, '#destroy' do

  integrate_views

  let(:share) { Factory.create(:share) }
  let(:valid_params) { { :id => share.id } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  it 'destroys the share' do
    delete(:destroy, valid_params)
    Share.find_by_id(share.id).should be_nil
  end

  context 'format html' do
    it 'redirects to shares/index' do
      delete(:destroy, valid_params)
      response.should redirect_to(shares_path)
    end
  end

  context 'format xml' do
    it 'renders status "OK"' do
      delete(:destroy, xml_params)
      response.status.should == '200 OK'
    end
  end

end
