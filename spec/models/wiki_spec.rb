require 'spec_helper'

describe Wiki do

  describe 'associations' do
    it { should belong_to(:project) }
    it { should have_many(:pages).dependent(:destroy) }
    it { should have_many(:redirects).dependent(:delete_all) }
  end

  describe '#valid?' do
    it { should validate_presence_of(:start_page) }
  end

  describe "find_or_new_page(title)" do
    let(:wiki) { Wiki.create!(:project_id => 5, :start_page => 'something') }

    describe '#find_or_new_page' do
      it 'creates a new wiki page' do
        wiki_page = wiki.find_or_new_page('title')
        wiki_page.title.should == 'Title'
      end
    end
  end

end
