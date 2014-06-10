require 'spec_helper'

describe Issue, 'validations' do

  it { should validate_presence_of(:subject) }

  it { should ensure_length_of(:subject).is_at_most(255) }

end
