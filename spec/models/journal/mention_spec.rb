require 'spec_helper'

describe Journal, '#mention' do

  it 'creates a mention' do
    issue = Issue.new({:subject => 'something'})
    journal = Journal.new({:user_id => 5, :issue => issue})
    expect {
      journal.mention(5, 10, 'note')
    }.to change(Notification, :count).by(1)
  end

end
