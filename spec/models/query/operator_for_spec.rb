require 'spec_helper'

describe Query, '#operator_for' do

  let(:query) { Query.new }

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
