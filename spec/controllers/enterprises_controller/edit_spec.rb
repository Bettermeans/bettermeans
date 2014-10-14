require 'spec_helper'

describe EnterprisesController, '#edit' do

  let(:enterprise) { Factory.create(:enterprise) }
  let(:valid_params) { { :id => enterprise.id } }

  it 'renders the "edit" template' do
    get(:edit, valid_params)
    response.should render_template('enterprises/edit')
  end

end
