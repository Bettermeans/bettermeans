require 'spec_helper'

describe WikiController, '#index' do

  let(:user) { Factory.create(:user) }
  let(:project) { Factory.create(:project) }
  let(:wiki) { project.reload.wiki }
  let(:wiki_page) { Factory.create(:wiki_page, :wiki => wiki, :title => 'wat') }
  let!(:wiki_content) do
    WikiContent.create!(:text => 'some text', :page => wiki_page)
  end
  let(:valid_params) { { :page => wiki_page.title, :id => project.id } }

  before(:each) do
    login_as(user)
  end

  context 'when the page requested does not already exist' do
    context 'when the user is allowed to edit wiki pages for the project' do
      it 'renders the "edit" template' do
        user.add_as_core(project)
        get(:index, valid_params.merge(:page => 'foo'))
        response.should render_template('wiki/edit')
      end
    end

    context 'when the user is not allowed to edit wiki pages for the project' do
      it 'renders a 404' do
        get(:index, valid_params.merge(:page => 'foo'))
        response.status.should == '404 Not Found'
      end
    end
  end

  context 'when given a params[:version]' do
    context 'when user is not allowed to view wiki edits' do
      it 'redirects to the current version' do
        non_member_role = Role.find_by_name('Non member')
        non_member_role.permissions -= [:view_wiki_edits]
        non_member_role.save!
        get(:index, valid_params.merge(:version => 'pie'))
        response.should redirect_to(:action => :index)
      end
    end
  end

end
