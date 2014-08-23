require 'spec_helper'

describe Credit, '#previously_issued' do

  let(:credit) { Credit.new(:amount => 100) }

  context 'when issued_on and created_at differ more than 2 millisconds' do
    it 'returns true' do
      credit.issued_on = 10
      credit.created_at = 1
      credit.previously_issued.should be true
    end
  end

end
