Feature:(#6137) Browse Bettermeans only shows public workstreams

Background:
  Given I am logged in
  And I am not an administrator

Scenario: I can see any public workstreams
  Given I belong to a public workstream
  When I go to Browse Bettermeans
  Then I see it
  Given a public workstream that I do not belong to
  When I go to Browse Bettermeans
  Then I see it

Scenario: I cannot see private workstreams even when I am a member
  Given a private workstream that I do not belong to
  When I go to Browse Bettermeans
  Then I do not see it
  Given I belong to a private workstream
  When I go to Browse Bettermeans
  Then I do not see it

Scenario: I cannot see private workstreams that I do not belong to but Anonymous does
  Given a private workstream that I do not belong to
  But the anonymous user is a member
  When I go to Browse Bettermeans
  Then I do not see it

Scenario: Administrators cannot see any private workstreams
  Given I am an administrator
  And a private workstream that I do not belong to
  When I go to Browse Bettermeans
  Then I do not see it
  Given I belong to a private workstream
  When I go to Browse Bettermeans
  Then I do not see it

Scenario: Anonymous users can see all public workstreams
  Given I am not logged in
  Given I belong to a public workstream
  When I go to Browse Bettermeans
  Then I see it
  Given a public workstream that I do not belong to
  When I go to Browse Bettermeans
  Then I see it

Scenario: Anonymous users cannot see any private workstreams at all
  Given I am not logged in
  And a private workstream that I do not belong to
  When I go to Browse Bettermeans
  Then I do not see it
  Given I belong to a private workstream
  When I go to Browse Bettermeans
  Then I do not see it

Scenario: It only shows root workstreams
  Given a public workstream that is a child of another public workstream
  When I go to Browse Bettermeans
  Then I do not see it

Scenario: It only shows the top 10 workstreams
  Given there are more than 10 workstreams available
  When I go to Browse Bettermeans
  Then I only see 10

@ajax
Scenario: I cannot see any private workstreams when I load more
  Given there are 10 workstreams available
  And a private workstream that I do not belong to
  And I belong to a private workstream
  When I go to Browse Bettermeans
  And I load more
  And I wait until loaded
  Then I only see 10

@ajax
Scenario: I can see public workstreams when I load more
  Given there are 11 workstreams available
  When I go to Browse Bettermeans
  And I load more
  And I wait until loaded
  Then I see 11
