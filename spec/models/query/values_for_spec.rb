require 'spec_helper'

describe Query, '#values_for' do

  let(:query) { Query.new }

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
