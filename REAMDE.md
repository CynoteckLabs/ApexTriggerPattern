
# Apex Trigger Pattern

A robust and lightweight trigger handler pattern implementation. Uses best practices to ensure:

* One trigger per object
* Configuration based enable/ disable triggers
* Add/ remove trigger handler without code changes
* Skip triggers for specific user(s) - helpful for bulk data load jobs, during business hours

## Pre-Requisites
1. Custom settings of list type should be enabled (To enable go to Schema settings and enable)
2. Ensure there are no metadata conflicts within your Salesforce instance
3. Download and install code within your Salesforce instance

## Usage
For trigger implementation of an sObject, follow these steps
1. Create an apex handler class which implements ITrigger interface (details provided below within Handler Design)
2. Create a record in Trigger Config (custom setting) specifying
    * Name = Sobject API Name
    * Active ? = TRUE
    * Apex Handler = <Name of class created in step 1>

## Handler Design
Apex Handler class exposes functions to handle individual trigger execution contexts. It can help in:
* Minimizing SOQL/ SOQL and heap memory queries by reusing already retrieved records
* Minimize DMLs by caching all DML operations for a single context
* Avoid governor limits

## Sample Implementation
A sample implementation of Account trigger handler is included within code. This is merely for demo purposes and provides boilerplate code.

## Best Practices
* For before context, retrieve all records within bulkBefore method
* For after context, retrieve all records within bulkAfter method
* Execute all governed resource (DML statements, future method invocation etc.) within andFinally method
* (MUST HAVE) As single record handler methods (beforeInsert, beforeUpdate, beforeDelete, afterInsert, afterUpdate, afterDelete) are invoked within a loop, they should not invoke any SOQL/ SOQL queries, DML statements, Future methods

## Setup Considerations
To avoid throwing undesired exceptions, we have skipped following scenarios
  * Trigger config record doesn't exist for sObject
  * Trigger config record is inactive
  * Trigger config record contains apex handler which does not inherit ITrigger interface

Underlying assumption with this approach is that administrator/ developer need to ensure apprpripate setup of trigger config records for expected result.