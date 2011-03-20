Feature:(#6137) The Latest Public Workstreams list only shows public and my private workstreams

Background: 
  Given I am logged in
  
Scenario: Private workstreams that I am a member of show in Latest Public Workstreams
  Given I have one private workstream
  When I go to Browse Bettermeans
  Then it shows in the Latest Public Workstreams list

Scenario: Private workstreams that I am not a member of do not show in Latest Public Workstreams
  Given there is one private workstream I am not a member of
  When I go to Browse Bettermeans
  Then it does not show in the Latest Public Workstreams list

Scenario: Public workstreams that I am a member of show in Latest Public Workstreams
  Given there is one public workstream I am a member of
  When I go to Browse Bettermeans
  Then it shows in the Latest Public Workstreams list

Scenario: Public workstreams that I am not a member of show in Latest Public Workstreams
  Given there is one public workstream I am not a member of
  When I go to Browse Bettermeans
  Then it shows in the Latest Public Workstreams list
  
Scenario: Anonymous user is a member of a private project that I am not
  Given there is one private workstream I am not a member of
  And the anonymous user is a member
  When I go to Browse Bettermeans
  Then it does not show in the Latest Public Workstreams list
  
Scenario: Administrators can see anyone's private workstreams
Scenario: Anonymous user can see all public workstreams
Scenario: Anonymous user can see any private workstreams it is a member of

Feature:(#6137) The Most Active Public Workstreams list must behave like the Latest Public Workstreams list