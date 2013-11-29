require 'spec_helper'

describe Query do

  let(:query) { Query.new }

  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:user) }
  end

  describe '#valid?' do
    it { should validate_presence_of(:name) }
    it { should ensure_length_of(:name).is_at_most(255) }
  end

  describe '#after_initialize' do
    context 'if project is nil' do
      it 'sets @is_for_all to true' do
        query.instance_variable_get(:@is_for_all).should be_true
      end
    end

    context 'if project is not nil' do
      it 'sets @is_for_all to false' do
        query = Query.new(:project => Project.new)
        query.instance_variable_get(:@is_for_all).should be_false
      end
    end
  end

  describe '#has_filter?' do
    it "using field 'status_id' returns filters and filters[field]" do
      field = 'status_id'
      query.has_filter?(field).should ==
        {:operator=>"o", :values=>[""]}
    end
  end

  describe '#grouped?' do
    it 'returns true if query is a grouped query' do
      query.group_by = true
      query.grouped?.should be_true
    end
  end

end
