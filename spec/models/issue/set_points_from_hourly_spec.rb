require 'spec_helper'
describe Issue, '#set_points_from_hourly' do

  let(:tracker) { Tracker.find_by_name(hourly_name) }
  let(:issue) { Factory.create(:issue, :tracker => tracker) }
  let(:hourly_name) { I18n.t(:default_issue_tracker_hourly) }

  it 'return unless the issue is hourly' do
    tracker.update_attributes!(:name => 'not_hourly')
    issue.set_points_from_hourly
    issue.points.should be nil
  end
end