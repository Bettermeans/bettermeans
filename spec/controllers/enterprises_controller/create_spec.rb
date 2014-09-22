require 'spec_helper'

describe EnterprisesController, '#create' do

  integrate_views

  let(:valid_params) { { :enterprise => { :name => 'help me!' } } }
  let(:xml_params) { valid_params.merge(:format => 'xml') }

  context 'if the enterprise saves' do
    context 'format html' do
      it 'flashes a success message' do
        flash.stub(:sweep)
        post(:create, valid_params)
        flash[:success].should match(/successfully created/i)
      end

      it 'redirects to enterprises show' do
        post(:create, valid_params)
        response.should redirect_to(assigns(:enterprise))
      end

      it 'sets the fields on the enterprise' do
        post(:create, valid_params)
        enterprise = Enterprise.first
        enterprise.name.should == 'help me!'
      end
    end

    context 'format xml' do
      it 'renders the enterprise as xml' do
        post(:create, xml_params)
        response.body.should == assigns(:enterprise).to_xml
      end

      it 'renders status "Created"' do
        post(:create, xml_params)
        response.status.should == '201 Created'
      end

      it 'renders the location of the enterprise' do
        post(:create, xml_params)
        response.location.should == enterprise_url(assigns(:enterprise))
      end
    end
  end

  context 'if the enterprise does not save' do

    let(:enterprise) { Enterprise.new }

    before(:each) do
      enterprise.stub(:valid?).and_return(false)
      enterprise.errors.add(:wat, 'an error')
      Enterprise.stub(:new).and_return(enterprise)
    end

    context 'format html' do
      it 'renders the "new" template' do
        post(:create, valid_params)
        response.should render_template('enterprises/new')
      end
    end

    context 'format xml' do
      it 'renders the errors on the enterprise as xml' do
        post(:create, xml_params)
        response.body.should == enterprise.errors.to_xml
      end

      it 'renders status "Unprocessable Entity"' do
        post(:create, xml_params)
        response.status.should == '422 Unprocessable Entity'
      end
    end
  end

end
