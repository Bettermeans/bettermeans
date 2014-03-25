require 'spec_helper'

describe ActivityStreamsHelper, '#verb_translation_key' do

  it 'returns the translation key for the given verb' do
    helper.verb_translation_key('some_key').should == 'activity.some_key'
  end

end
