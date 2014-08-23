require 'spec_helper'

describe Comment, 'validations' do

  it { should validate_presence_of(:commented) }

end
