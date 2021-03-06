@edit @articles
Feature: Edit a document
  In order to [goal]
  [stakeholder]
  wants [behaviour]
 
  @pending
  Scenario: Visit Document Edit Page
    Given I am logged in as "contentAccessTeam1@example.com" 
    And I am on the edit document page for hull:1729 
    And I should see an inline edit containing "Towards a Repository-enabled Scholars Workbench : RepoMMan, REMAP and Hydra"

  Scenario: Viewing browse/edit buttons
    Given I am logged in as "contentAccessTeam1@example.com" 
    And I am on the edit document page for hull:1729
    Then I should see a "span" tag with a "class" attribute of "edit-browse"
    
