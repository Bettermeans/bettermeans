require 'spec_helper'

describe MailHandler, '.receive' do

  let(:fake_email) {
<<-EMAIL
Delivered-To: blah@blah.com
Subject: Here's your email

Hello dood
EMAIL
  }

  def handler_options
    MailHandler.send(:class_variable_get, :@@handler_options)
  end

  it 'does not change the options passed in' do
    mailer_options = { :blah => 'foo' }
    MailHandler.receive(fake_email, mailer_options)
    mailer_options.should == { :blah => 'foo' }
  end

  it 'sets @@handler_options[:issue]' do
    MailHandler.receive(fake_email)
    handler_options[:issue].should == {}
  end

  it 'leaves @@handler_options[:issue] when given' do
    mailer_options = { :issue => { :blah => 'foo' } }
    MailHandler.receive(fake_email, mailer_options)
    handler_options[:issue].should == { :blah => 'foo' }
  end

  it 'splits and strips @@handler_options[:allow_override]' do
    mailer_options = { :allow_override => 'a , b' }
    MailHandler.receive(fake_email, mailer_options)
    handler_options[:allow_override].should == ['a', 'b', 'project', 'status']
  end

  it 'sets @@handler_options[:allow_override] when not given' do
    MailHandler.receive(fake_email)
    handler_options[:allow_override].should == ['project', 'status']
  end

  it 'does not add "project" to overrides when given with issue' do
    mailer_options = { :issue => { :project => 'foo' } }
    MailHandler.receive(fake_email, mailer_options)
    handler_options[:allow_override].should == ['status']
  end

  it 'does not add "status" to overrides when given with issue' do
    mailer_options = { :issue => { :status => 'foo' } }
    MailHandler.receive(fake_email, mailer_options)
    handler_options[:allow_override].should == ['project']
  end

  it 'sets @@handler_options[:no_permission_check] to false by default' do
    MailHandler.receive(fake_email)
    handler_options[:no_permission_check].should == false
  end

  it 'sets @@handler_options[:no_permission_check] to true when given 1' do
    mailer_options = { :no_permission_check => 1 }
    MailHandler.receive(fake_email, mailer_options)
    handler_options[:no_permission_check].should == true
  end

  it 'returns something' do
    MailHandler.receive(fake_email).should_not be_nil
  end

end
