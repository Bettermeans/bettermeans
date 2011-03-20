Feature:(#6137) Browse Bettermeans only shows public and my private workstreams

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
  
Scenario: I cannot see private workstreams unless I am a member
  Given a private workstream that I do not belong to
  When I go to Browse Bettermeans
  Then I do not see it
  Given I belong to a private workstream 
  When I go to Browse Bettermeans
  Then I see it

Scenario: I cannot see private workstreams that I do not belong to but Anonymous does
  Given a private workstream that I do not belong to
  But the anonymous user is a member
  When I go to Browse Bettermeans
  Then I do not see it
  
Scenario: Administrators can see all private workstreams
  Given I am an administrator
  And a private workstream that I do not belong to
  When I go to Browse Bettermeans
  Then I see it
  
Scenario: Anonymous users can see all public workstreams
  Given I am not logged in
  And a private workstream that I do not belong to
  And the anonymous user is a member
  When I go to Browse Bettermeans
  Then I see it
  
Scenario: Anonymous users cannot see any private workstreams they do not belong to
  Given I am not logged in
  And a private workstream that I do not belong to
  When I go to Browse Bettermeans
  Then I do not see it