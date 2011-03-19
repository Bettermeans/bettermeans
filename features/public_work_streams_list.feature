Feature: [#6137] Public work stream list screen does not show private work streams

Background:
  Given I am logged in
  
Scenario: My private work streams show in Latest Public Workstreams
Given I have one private workstream
When I go to Browse Bettermeans
Then it shows in the Latest Public Workstreams list

Scenario: Any other private work streams do not show in Latest Public Workstreams
Given there is one private workstream I am not a member of
When I go to Browse Bettermeans
Then it does not show in the Latest Public Workstreams list