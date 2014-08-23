require 'spec_helper'

describe Wiki, 'validations' do

  it { should validate_presence_of(:start_page) }

end
