require 'spec_helper'

describe Invitation, '#status_name' do

  let(:invitation) { Invitation.new }

  it 'returns pending when the status is pending' do
    invitation.status = Invitation::PENDING
    invitation.status_name.should == "Pending"
  end

  it 'returns accepted when the status is accepted' do
    invitation.status = Invitation::ACCEPTED
    invitation.status_name.should == "Accepted"
  end

  it 'returns unknown when the status is something else' do
    invitation.status = 32
    invitation.status_name.should == "Unknown"
  end

end
