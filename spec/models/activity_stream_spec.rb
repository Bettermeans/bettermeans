require 'spec_helper'

describe ActivityStream do

  let(:activity_stream) {
    ActivityStream.create!
    ActivityStream.new
  }

  describe '#soft_destroy' do
    it 'does not delete the model' do
      activity_stream.soft_destroy
      expect {
        ActivityStream.find(activity_stream.id)
      }.to_not raise_error
    end

    it 'sets the status to deleted' do
      activity_stream.soft_destroy
      activity_stream.status.should == ActivityStream::DELETED
    end
  end

end
