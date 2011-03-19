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