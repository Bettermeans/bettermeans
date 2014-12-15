require 'spec_helper'

describe Mailer, '#issue_add' do

  let(:user) { Factory.create(:user) }
  let(:issue) { Factory.create(:issue, :author => user) }

  before(:each) do
    user.pref[:no_self_notified] = false
    user.pref.save!
  end

  def header(mail, name)
    mail["x-bettermeans-#{name}"].to_s
  end

  it 'sets basic headers' do
    mail = Mailer.deliver_issue_add(issue)
    header(mail, 'project').should == issue.project.identifier
    header(mail, 'issue-id').should == issue.id.to_s
    header(mail, 'issue-author').should == user.login
    header(mail, 'issue-assignee').should == ''
  end

  it 'sets assignee header when issue is assigned' do
    user_2 = Factory.create(:user)
    issue.update_attributes!(:assigned_to => user_2)
    mail = Mailer.deliver_issue_add(issue)
    header(mail, 'issue-assignee').should == user_2.login
  end

  it 'sets the mailer message_id' do
    mail = Mailer.deliver_issue_add(issue)
    bits = [
      'redmine',
      "issue-#{issue.id}",
      issue.created_at.strftime('%Y%m%d%H%M%S'),
    ]
    mail.message_id.should == "<#{bits.join('.')}@better.boon.gl>"
  end

  it 'does not email the issue author if configured not to notify self' do
    user.pref[:no_self_notified] = true
    user.pref.save!

    user_2 = Factory.create(:user)
    user_2.update_attributes!(:mail_notification => true)
    user_2.add_as_core(issue.project)

    mail = Mailer.deliver_issue_add(issue)
    mail.bcc.should == [user_2.mail]
  end

  it 'sends to author if not configured to notify self' do
    user_2 = Factory.create(:user)
    user_2.update_attributes!(:mail_notification => true)
    user_2.add_as_core(issue.project)

    mail = Mailer.deliver_issue_add(issue)
    mail.bcc.sort.should == [user.mail, user_2.mail]
  end

end
