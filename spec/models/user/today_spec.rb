require 'spec_helper'

describe User, '#today' do

  let(:user) { User.new }
  let(:today) { Time.parse("2014-04-04 00:00 GMT") }

  before do
    @old_time_zone = Time.zone
    Time.zone = "UTC"
  end

  after { Time.zone = @old_time_zone }

  context "when the user has a time zone" do
    it "returns the date in the user's time zone" do
      user.pref.time_zone = "Pacific Time (US & Canada)"

      Timecop.freeze(today) do
        user.today.should == Date.yesterday
      end
    end
  end

  context "when the user does not have a time zone" do
    it "returns the date in the default time zone" do
      user.pref.time_zone = nil

      Timecop.freeze(today) do
        user.today.should == Date.today
      end
    end
  end

end
