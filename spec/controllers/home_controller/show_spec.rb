require 'spec_helper'

describe HomeController, '#show' do

  it 'renders the pricing view when params[:page] is set to pricing' do
     get(:show, :page => 'pricing')
     response.should render_template('home/pricing')
  end

end
