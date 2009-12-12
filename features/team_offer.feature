# @no-txn
Feature: Ownership offer
  In order to invite others to be core team members with me
  As a core team member
  I want to offer core memberships on a team to someone else
  
  Background: 
    Given the following users exist
    | login   | password | firstname | lastname | admin |
    | shereef | shereef  | shereef   | bishay   | true  |
    | karim   | karim    | karim     | bishay   | false |


    Given an enterprise "myenterprise" exists with name: "Enterprise"
    And a project "myproject" exists with name: "Workstream1", enterprise: that enterprise
    And kraim is a Core Member of project "Workstream1"
  
  # @selenium
  Scenario: Invite a contributor to be a core member
    Given I am logged in as shereef
    When I go to the show page for that project
    Then I should see "Workstream1" within "h1"
    When I follow "Items"
    Then I should see "My issue"
    Given karim is a Core Member of project "Workstream1"
    And I am a Core Member of project "Workstream1"
    When I follow "My issue"
    Then I should see "Offer Ownership"
    When I follow "Offer Ownership"
    Then I should see "Choose someone"
    When I select "karim bishay" from "responder_id"
    And I press "Offer Ownership"
    And I am logged in as karim
    Then I should see "new notification(s)"
    When I follow "new notifications(s)"
    Then I should see "Offer"
    # Then I should see "Recind ownership"
    

    # And I add an issue called "First issue" to the project called "Workstream1"    
    #Given I go to the show page for that issue
    # Then I should see "First issue"
    # And the project "Workstream 1" exists
    # And the issue "Very important issue" exists
    # And the issue "Not as important issue" exists    
    # When I offer "Very important task" to "Karim"
    # Then I should see ""
  
  
  
  
