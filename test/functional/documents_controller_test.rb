# BetterMeans - Work 2.0
# Copyright (C) 2006-2011  See readme for details and license#

require File.dirname(__FILE__) + '/../test_helper'
require 'documents_controller'

# Re-raise errors caught by the controller.
class DocumentsController; def rescue_action(e) raise e end; end

class DocumentsControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles, :enabled_modules, :documents, :enumerations
  
  def setup
    @controller = DocumentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end
  
  def test_index_routing
    assert_routing(
      {:method => :get, :path => '/projects/567/documents'},
      :controller => 'documents', :action => 'index', :project_id => '567'
    )
  end
  
  def test_index
    # Sets a default category
    e = Enumeration.find_by_name('Technical documentation')
    e.update_attributes(:is_default => true)
    
    get :index, :project_id => 'ecookbook'
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:grouped)
    
    # Default category selected in the new document form
    assert_tag :select, :attributes => {:name => 'document[category_id]'},
                        :child => {:tag => 'option', :attributes => {:selected => 'selected'},
                                                     :content => 'Technical documentation'}
  end
  
  def test_new_routing
    assert_routing(
      {:method => :get, :path => '/projects/567/documents/new'},
      :controller => 'documents', :action => 'new', :project_id => '567'
    )
    assert_recognizes(
      {:controller => 'documents', :action => 'new', :project_id => '567'},
      {:method => :post, :path => '/projects/567/documents'}
    )
  end
  
  def test_new_with_one_attachment
    ActionMailer::Base.deliveries.clear
    Setting.notified_events << 'document_added'
    @request.session[:user_id] = 2
    set_tmp_attachments_directory
    
    post :new, :project_id => 'ecookbook',
               :document => { :title => 'DocumentsControllerTest#test_post_new',
                              :description => 'This is a new document',
                              :category_id => 2},
               :attachments => {'1' => {'file' => uploaded_test_file('testfile.txt', 'text/plain')}}
               
    assert_redirected_to 'projects/ecookbook/documents'
    
    document = Document.find_by_title('DocumentsControllerTest#test_post_new')
    assert_not_nil document
    assert_equal Enumeration.find(2), document.category
    assert_equal 1, document.attachments.size
    assert_equal 'testfile.txt', document.attachments.first.filename
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
  
  def test_edit_routing
    assert_routing(
      {:method => :get, :path => '/documents/22/edit'},
      :controller => 'documents', :action => 'edit', :id => '22'
    )
    assert_recognizes(#TODO: should be using PUT on document URI
      {:controller => 'documents', :action => 'edit', :id => '567'},
      {:method => :post, :path => '/documents/567/edit'}
    )
  end
  
  def test_show_routing
    assert_routing(
      {:method => :get, :path => '/documents/22'},
      :controller => 'documents', :action => 'show', :id => '22'
    )
  end
  
  def test_destroy_routing
    assert_recognizes(#TODO: should be using DELETE on document URI
      {:controller => 'documents', :action => 'destroy', :id => '567'},
      {:method => :post, :path => '/documents/567/destroy'}
    )
  end
  
  def test_destroy
    @request.session[:user_id] = 2
    post :destroy, :id => 1
    assert_redirected_to 'projects/ecookbook/documents'
    assert_nil Document.find_by_id(1)
  end
end
