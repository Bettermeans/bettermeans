require 'spec_helper'

describe Query, '#has_filter?' do

  let(:query) { Query.new }

  it "using field 'status_id' returns filters and filters[field]" do
    query.has_filter?('status_id').should be true
  end

end
