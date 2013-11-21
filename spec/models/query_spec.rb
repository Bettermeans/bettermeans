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

  # should project be stubbed? what should be returned?
  describe '#after_initialize' do
    context 'if project is nil' do
      it 'stores nil project and return @is_for_all' do
        query.after_initialize.should be_true
      end
    end
  end

  # not sure how this one works
  # 1. how one would know the output without console
  # 2. what the point of setting up method like this would be
  describe '#has_filter?' do
    it 'returns filters and filters[field]' do
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
