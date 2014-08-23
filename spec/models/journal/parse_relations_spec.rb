require 'spec_helper'

describe Journal, '#parse_relations' do

  it 'puts in a delayed job' do
    journal = Journal.new
    journal.should_receive(:send_later).with(:parse_relations_delayed)
    journal.parse_relations
  end

end
