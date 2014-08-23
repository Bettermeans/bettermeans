require 'spec_helper'

describe Credit, '#issue_shares' do

  let(:credit) { Credit.new(:amount => 100) }

  context 'when not a previously_issued credit' do
    it 'creates new shares' do
      credit.stub(:previously_issued).and_return(false)
      expect {
        credit.issue_shares
      }.to change(Share, :count)
    end
  end

end
