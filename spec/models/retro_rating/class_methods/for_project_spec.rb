require 'spec_helper'

describe RetroRating, '.for_project' do

  it 'returns ratings assocated with the given project id' do
    project = Factory.create(:project)
    retro1 = Factory.create(:retro, :project => project)
    rating1 = Factory.create(:retro_rating, :retro => retro1)
    rating2 = Factory.create(:retro_rating)

    RetroRating.for_project(project.id).should == [rating1]

  end

end
