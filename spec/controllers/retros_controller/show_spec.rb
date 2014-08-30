require 'spec_helper'

describe RetrosController, '#show' do

  let(:retro) { Factory.create(:retro, :project => project) }
  let(:project) { Factory.create(:project) }
  let(:valid_params) { { :id => retro.id } }

  it 'assigns @retro' do
    get(:show, valid_params)
    assigns(:retro).should == retro
  end

  it 'assigns @team_hash' do
    get(:show, valid_params)
    assigns(:team_hash).should == {}
  end

  it 'assigns @final_hash' do
    get(:show, valid_params)
    assigns(:final_hash).should == {}
  end

  it 'assigns @user_retro_hash' do
    get(:show, valid_params)
    assigns(:user_retro_hash).should == {}
  end


  it 'assigns @total_points' do
    get(:show, valid_params)
    assigns(:total_points).should == 0
  end

  it 'assigns @total_ideas' do
    get(:show, valid_params)
    assigns(:total_ideas).should == 0
  end

  it 'assigns @max_range' do
    get(:show, valid_params)
    assigns(:max_range).should == 0
  end

  it 'assigns @pie_data_points' do
    get(:show, valid_params)
    assigns(:pie_data_points).should == []
  end

  it 'assigns @pie_labels_points' do
    get(:show, valid_params)
    assigns(:pie_labels_points).should == []
  end

  it 'assigns @max_points' do
    get(:show, valid_params)
    assigns(:max_points).should == 0
  end

end
