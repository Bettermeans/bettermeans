require "spec_helper"

describe Credit do

  describe 'associations' do
    it { should belong_to(:owner) }
    it { should belong_to(:project) }
  end

  let(:credit) { Credit.new(:amount => 100) }

  describe "#issue_day" do
    it "returns a string for date it was issued on" do
      time = Time.now
      credit.issued_on = time
      credit.issue_day.should == time.strftime('%D')
    end
  end

  describe "#disable" do
    it "sets enabled status to false" do
      credit.enabled = true
      credit.disable
      credit.enabled.should == false
    end

    it 'returns the result of the save' do
      credit.stub(:save).and_return(false)
      credit.disable.should be_false
    end
  end

  describe "#enable" do
    it "sets enabled status to true" do
      credit.enabled = false
      credit.enable
      credit.enabled.should == true
    end

    it 'returns the result of the save' do
      credit.stub(:save).and_return(true)
      credit.enable.should == true
    end
  end

  describe '#issue_shares' do
    context 'when not a previously_issued credit' do
      credit.previously_issued = false
      it 'creates new shares' do
        expect {
          credit.issue_shares
        }.to change(Share, :count)
      end
    end
  end

  describe '#previously_issued' do
    context 'when issued_on and created_at differ more than 2 millisconds' do
      it 'returns true' do
        credit.issued_on = 10
        credit.created_at = 1
        credit.previously_issued.should be_true
      end
    end
  end

end
