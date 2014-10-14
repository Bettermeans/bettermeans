require 'spec_helper'

describe EnterprisesController, '#destroy' do

  let(:enterprise) { Factory.create(:enterprise) }
  let(:valid_params) { { :id => enterprise.id } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  it 'destroys the enterprise' do
    delete(:destroy, valid_params)
    Enterprise.find_by_id(enterprise.id).should be_nil
  end

  context 'format html' do
    it 'redirects to enterprises/index' do
      delete(:destroy, valid_params)
      response.should redirect_to(enterprises_path)
    end
  end

  context 'format xml' do
    it 'renders status "OK"' do
      delete(:destroy, xml_params)
      response.status.should == '200 OK'
    end
  end

end
