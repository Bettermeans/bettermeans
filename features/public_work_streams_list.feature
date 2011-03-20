Feature:(#6137) Browse Bettermeans only shows public and my private workstreams

Background: 
  Given I am logged in
  And I am not an administrator
  
Scenario: Public workstreams that I am a member of are visible
  Given there is one public workstream I am a member of
  When I go to Browse Bettermeans
  Then it is visible
  
Scenario: Public workstreams that I am not a member of are not visible
  Given there is one public workstream I am not a member of
  When I go to Browse Bettermeans
  Then it is visible

Scenario: Private workstreams that I am a member of are visible
  Given I have one private workstream
  When I go to Browse Bettermeans
  Then it is visible
  
Scenario: Private workstreams that I am not a member of are not visible
  Given there is one private workstream I am not a member of
  When I go to Browse Bettermeans
  Then it is not visible

Scenario: Private workstreams that I am not a member of but Anonymous is are not visible
  Given there is one private workstream I am not a member of
  And the anonymous user is a member
  When I go to Browse Bettermeans
  Then it is not visible
  
Scenario: Administrators can see all private workstreams
  Given I am an administrator
  And there is one private workstream I am not a member of
  When I go to Browse Bettermeans
  Then it is visible
  
Scenario: Anonymous users can see all public workstreams
  Given I am not logged in
  And there is one private workstream I am not a member of
  And the anonymous user is a member
  When I go to Browse Bettermeans
  Then it is visible
  
Scenario: Anonymous users cannot see any private workstreams they are not members of
  Given I am not logged in
  And there is one private workstream I am not a member of
  When I go to Browse Bettermeans
  Then it is not visible