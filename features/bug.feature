Feature: (#7551) New dash data does not throw error when the include_subworkstreams parameter is supplied

Background: 
  Given I am logged in
  And I am not an administrator

Scenario: New dash data throws error
  Given I belong to a public workstream
  When I go to dash data 
  Then I do not see an error screen