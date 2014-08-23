require 'spec_helper'

describe Enumeration, '#option_name' do

  let(:enumeration) { Enumeration.new }

  it 'returns nil' do
    enumeration.option_name.should be_nil
  end

end
