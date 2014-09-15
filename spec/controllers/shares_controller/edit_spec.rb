require 'spec_helper'

describe SharesController, '#edit' do

  integrate_views

  let(:share) { Factory.create(:share) }
  let(:valid_params) { { :id => share.id } }

  it 'renders the "edit" template' do
    get(:edit, valid_params)
    response.should render_template('shares/edit')
  end

end
