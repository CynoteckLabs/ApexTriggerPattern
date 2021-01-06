
# Apex Trigger Pattern

A robust and lightweight trigger handler pattern implementatio. Uses best practices to ensure:

* Enables Bulkification with shared context
* Greater control over order of execution
* Configuration based enable/ disable triggers
* Add/ remove trigger handler without code changes
* Skip triggers for specific user(s) - helpful for bulk data load jobs, during business hours

## Pre-Requisites
1. Custom settings of list type should be enabled (To enable go to Schema settings and enable)
2. Ensure there are no metadata conflicts within your Salesforce instance
3. Download and install code within your Salesforce instance

## Usage
For trigger implementation of an sObject, follow these steps
1. Create Apex Trigger for object and invoke Trigger Handler (For Sample code refer [triggerOnAccount.trigger](src/triggers/triggerOnAccount.trigger))
2. Create an apex handler class which implements ITrigger interface (details provided below within Handler Design). (For sample code refer [AccountHandler.cls](src/classes/AccountHandler.cls))
2. Create a record in Trigger Config (custom setting) specifying
    * Name = Sobject API Name (for e.g. **Account** or **Invoice__c** )
    * Active ? = TRUE
    * Apex Handler = <Name of class created in step 2>

## Trigger Handler Design
Apex Trigger Handler class exposes functions to handle individual trigger execution contexts. It can help in:
* Minimizing SOQL/ SOQL and heap memory queries by reusing already retrieved records
* Minimize DMLs by caching all DML operations for a single context
* Avoid governor limits

## Sample Implementation
A sample implementation of Account trigger handler is included within code. This is merely for demo purposes and provides boilerplate code.

## Best Practices
* Data Retrieval - handle within bulk methods (bulkBefore, bulkAfter)
* Data Validations - handle within before methods (***beforeInsert, beforeUpdate, beforeDelete***)
* Data Qualifications - to qualify records for processing, handle within after methods (***afterInsert, afterUpdate, afterDelete***)
* Data Processing and updates (DML statements, future method invocation etc.) - handle within ***andFinally*** method
* **(MUST HAVE)** As single record handler methods (beforeInsert, beforeUpdate, beforeDelete, afterInsert, afterUpdate, afterDelete) are invoked within a loop, they should not invoke any SOQL/ SOQL queries, DML statements, Future methods

## Setup Considerations
To avoid throwing undesired exceptions, we have skipped following scenarios
  * Trigger config record doesn't exist for sObject
  * Trigger config record is inactive
  * Trigger config record contains apex handler which does not inherit ITrigger interface
  * Trigger config record has legitimate values for Name and Apex Handler fields

Underlying assumption with this approach is that administrator/ developer need to ensure appropriate setup of trigger config records for expected result.
