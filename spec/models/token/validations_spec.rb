require 'spec_helper'

describe Token, 'validations' do

  it do
    Factory.create(:token)
    should validate_uniqueness_of(:value)
  end

end
