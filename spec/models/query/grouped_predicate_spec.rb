require 'spec_helper'

describe Query, '#grouped?' do

  let(:query) { Query.new }

  it 'returns true if query is a grouped query' do
    query.group_by = true
    query.grouped?.should be true
  end

end
