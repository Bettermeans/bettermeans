require 'spec_helper'

describe DailyDigest, '.deliver' do

  before :each do
    DailyDigest.create!
    Mailer.stub(:send_later)
  end

  it 'should delete all DailyDigest and return an empty array' do
    DailyDigest.deliver
    DailyDigest.all.should == []
  end

end
