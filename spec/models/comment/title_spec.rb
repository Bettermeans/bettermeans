require 'spec_helper'

describe Comment, '#title' do

  let(:comment) { Comment.new }

  context "When commented type is 'News'" do
    let(:news) {
      News.create!( :title => "Rob is cool",
                    :description => "Comment by dklounge")
    }

    it 'returns the title of the news item' do
      comment.commented = news
      comment.title.should == "Rob is cool"
    end
  end

end
