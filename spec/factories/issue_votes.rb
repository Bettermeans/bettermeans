Factory.define :issue_vote do |f|
  f.association :user, :factory => :user
  f.association :issue, :factory => :issue
  f.points rand(20)
  f.vote_type IssueVote::AGREE_VOTE_TYPE
end
