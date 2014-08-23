require 'spec_helper'

describe Query, '#after_initialize' do

  let(:query) { Query.new }

  context 'if project is nil' do
    it 'sets @is_for_all to true' do
      query.instance_variable_get(:@is_for_all).should be true
    end
  end

  context 'if project is not nil' do
    it 'sets @is_for_all to false' do
      query = Query.new(:project => Project.new)
      query.instance_variable_get(:@is_for_all).should be false
    end
  end

end
