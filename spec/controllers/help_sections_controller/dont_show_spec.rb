require 'spec_helper'

describe HelpSectionsController, '#dont_show' do

  integrate_views

  let(:help_section) { Factory.create(:help_section) }
  let(:valid_params) { { :id => help_section.id } }
  let(:js_params) { valid_params.merge(:format => 'js') }

  it 'sets the help section not to show' do
    get(:dont_show, valid_params)
    help_section.reload.show.should be false
  end

  context 'format js' do
    it 'replaces help_section in the page' do
      get(:dont_show, js_params)
      response.body.should match(/replace/)
      response.body.should match(/help_section/)
    end
  end
end
