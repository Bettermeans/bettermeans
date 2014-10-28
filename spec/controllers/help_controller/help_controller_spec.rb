require 'spec_helper'

describe HelpController, '#show' do

  it 'renders the show template' do
    get(:show, :key => 'example')
    response.should render_template('show')
  end

end
