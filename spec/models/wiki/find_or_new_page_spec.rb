require 'spec_helper'

describe Wiki, 'find_or_new_page' do

  let(:wiki) { Wiki.create!(:project_id => 5, :start_page => 'something') }

  describe '#find_or_new_page' do
    it 'creates a new wiki page' do
      wiki_page = wiki.find_or_new_page('title')
      wiki_page.title.should == 'Title'
    end
  end

end
