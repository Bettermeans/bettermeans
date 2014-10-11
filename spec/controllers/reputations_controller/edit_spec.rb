require 'spec_helper'

describe ReputationsController, '#edit' do

  integrate_views

  let(:reputation) { Factory.create(:reputation) }
  let(:valid_params) { { :id => reputation.id } }

  it 'renders the "edit" template' do
    get(:edit, valid_params)
    response.should render_template('reputations/edit')
  end

end
