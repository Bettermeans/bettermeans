require 'spec_helper'

describe Enterprise, 'validations' do

  it { should validate_presence_of(:name) }

end
