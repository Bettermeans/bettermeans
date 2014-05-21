require 'spec_helper'

describe ApplicationHelper, '#general_translations' do

  context 'when there are no translations' do
    it 'returns an empty array' do
      I18n.backend.stub(:send).with(:init_translations)
      I18n.backend.stub(:send).with(:translations).and_return({})
      helper.general_translations.should == []
    end
  end

  context 'when there are no general translations' do
    it 'returns an empty array' do
      locale = I18n.locale
      I18n.backend.stub(:send).with(:init_translations)
      I18n.backend.stub(:send).with(:translations).and_return({ locale => {} })
      helper.general_translations.should == []
    end
  end

end
