require 'spec_helper'

describe Setting, '#[]=' do

  after(:each) { Setting.instance_variable_set(:@cached_settings, {}) }

  it 'changes the setting' do
    expect do
      Setting['app_title'] = 'Better'
    end.to change { Setting['app_title'] }.from('BetterMeans').to('Better')
    Setting.find_by_name('app_title').value.should == 'Better'
  end

end
