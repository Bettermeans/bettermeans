require 'spec_helper'

describe Issue, '#ready_for_canceled?' do

  let(:issue) { Issue.new }

  context 'when agree_total < 0 and updated prior to cutoff date' do
    it 'returns true' do
      cutoff_date = Setting::LAZY_MAJORITY_LENGTH
      issue.agree_total = -1
      issue.updated_at = DateTime.now - cutoff_date - 1
      issue.should be_ready_for_canceled
    end
  end

end
