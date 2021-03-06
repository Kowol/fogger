Feature:
  In order to exclude the table that has foreign key relations
  As a user
  I want the database refined so the foreign constraints are still valid

  Scenario: We want to exclude the table that is referenced by other table
    Given there is a source database
    And there is a table invoices with following columns:
      | name | type    | length | index   | nullable |
      | id   | integer |        | primary |          |
      | no   | string  | 64     |         |          |
    And the table invoices contains following data:
      | id | no      |
      | 1  | 01/2018 |
      | 2  | 02/2018 |
      | 3  | 03/2018 |
    And there is a table items with following columns:
      | name       | type    | length | index   | nullable |
      | id         | integer |        | primary |          |
      | invoice_id | integer |        |         | true     |
      | line       | string  | 64     |         |          |
    And the table items contains following data:
      | id | invoice_id | line      |
      | 1  | 1          | product 1 |
      | 2  | 1          | product 2 |
      | 3  | 2          | product 3 |
      | 4  | 3          | product 4 |
      | 5  | 3          | product 5 |
      | 6  | 3          | product 6 |
    And the items.invoice_id references invoices.id
    And there is an empty target database
    And the task queue is empty
    And the config test.yaml contains:
    """
    tables:
    excludes:
      - invoices
    """
    When I run "run" command with input:
      | --chunk-size | 1000      |
      | --file       | test.yaml |
      | --dont-wait  | true      |
    And worker processes 1 task
    And I run "finish" command with input:
      | --file | test.yaml |
    Then the command should exit with code 0
    And the table invoices in target database should have 0 rows
    And the table items in target database should have 6 rows
    And the table items in target database should contain rows:
      | id | invoice_id |
      | 1  |            |
      | 2  |            |
      | 3  |            |
      | 4  |            |
      | 5  |            |
      | 6  |            |
