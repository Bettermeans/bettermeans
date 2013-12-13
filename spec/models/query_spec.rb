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
      query.has_filter?('status_id').should be_true
    end
  end

  describe '#operator_for' do
    context 'when has_filter?(field) is true' do
      it 'returns operator associated with filter' do
        field = 'status_id'
        query.filters[field][:operator] = "one_of_the_operators"
        query.operator_for(field).should == "one_of_the_operators"
      end
    end

    context 'when has_filter?(field) is false' do
      it 'returns nil' do
        field = ''
        query.operator_for(field).should be_nil
      end
    end
  end

  describe '#values_for' do
    context 'when has_filter?(field) is true' do
      it 'returns values associated with filter' do
        field = 'status_id'
        query.filters[field][:values] = ["a given value", 3]
        query.values_for(field).should == ["a given value", 3]
      end
    end

    context 'when has_filter?(field) is false' do
      it 'returns nil' do
        field = ''
        query.values_for(field).should be_nil
      end
    end
  end

  describe '#grouped?' do
    it 'returns true if query is a grouped query' do
      query.group_by = true
      query.should be_grouped
    end
  end

end
