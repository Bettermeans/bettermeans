require 'spec_helper'

describe Setting, '#[]' do

  after(:each) { Setting.instance_variable_set(:@cached_settings, {}) }

  it 'returns the saved setting' do
    Setting['app_title'].should == 'BetterMeans'
  end

  it 'caches the setting' do
    Setting['app_title'].should == 'BetterMeans'
    Setting.find_by_name('app_title').update_attributes!(:value => 'Better')
    Setting['app_title'].should == 'BetterMeans'
    Setting.check_cache
    Setting['app_title'].should == 'Better'
  end

end
