require 'spec_helper'

describe ActivityStream, '#role_key' do

  let(:activity_stream) { ActivityStream.new }

  it 'raises an error when object type is not "memberrole"' do
    activity_stream.object_type = 'notmemberrole'
    expect do
      activity_stream.role_key
    end.to raise_error('not a role')
  end

  it 'returns the object name formatted when object type is "memberrole"' do
    activity_stream.object_type = 'memberrole'
    activity_stream.object_name = 'Bo Oger'

    activity_stream.role_key.should == 'role.bo_oger'
  end

end
