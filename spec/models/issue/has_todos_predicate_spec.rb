require 'spec_helper'

describe Issue, '#has_todos?' do

  let(:issue) { Issue.new }

  context 'when todos exist' do
    it 'returns true' do
      todo = Todo.new(:subject => "string")
      issue.stub(:todos).and_return([todo])
      issue.should be_has_todos
    end
  end

  context 'when todos do not exist' do
    it 'returns false' do
      issue.stub(:todos).and_return([])
      issue.has_todos?.should be_false
    end
  end

end
