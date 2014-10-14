require 'spec_helper'

describe QuotesController, '#edit' do

  let(:quote) { Factory.create(:quote) }
  let(:valid_params) { { :id => quote.id } }

  it 'renders the "edit" template' do
    get(:edit, valid_params)
    response.should render_template('quotes/edit')
  end

end
