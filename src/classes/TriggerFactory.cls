/**
 * Class TriggerFactory
 *
 * Used to instantiate and execute Trigger Handlers associated with sObjects.
 */
public with sharing class TriggerFactory
{
    /**
     * Public static method to create and execute a trigger handler
     *
     * Arguments:   Schema.sObjectType soType - Object type to process (SObject.sObjectType)
     *
     * Throws a TriggerException if no handler has been coded.
     */
    public static void initiateHandler(Schema.sObjectType soType)
    {
        TriggerConfig__c triggerConfig = TriggerConfig__c.getInstance(soType + '');

        /*
            Skip trigger if any of the following condition is true:
            a) Trigger Config record is not available
            b) Trigger config active status is FALSE
            c) Trigger config skip user name matches current user's username
        */

        if(triggerConfig != null && 
            isTriggerEnabled(triggerConfig) &&
            isTriggerDisabledForUser(triggerConfig) == false){
                
            // Get a handler appropriate to the object being processed
            ITrigger handler = getHandler(triggerConfig);
            
            // if handler is registered, execute handler
            if (handler != null)
            {
                // Execute the handler to fulfil the trigger
                execute(handler);
            }
        }
    }

    /**
     * private static method to determine if trigger is enabled/ disabled
     *
     * Arguments:   TriggerConfig__c config - configuration record for trigger
     */
    private static Boolean isTriggerEnabled(TriggerConfig__c config){
        return config.IsActive__c;
    }
    
    /**
     * private static method to determine if trigger is to be skipped for current user
     *
     * Arguments:   TriggerConfig__c config - configuration record for trigger
     */
    private static Boolean isTriggerDisabledForUser(TriggerConfig__c config){
        return (String.IsNotBlank(config.SkipForUsers__c) &&
                config.SkipForUsers__c.containsIgnoreCase(UserInfo.getUserName())) ;
    }

    /**
     * private static method to control the execution of the handler
     *
     * Arguments:   ITrigger handler - A Trigger Handler to execute
     */ 
    private static void execute(ITrigger handler)
    {
        // Before Trigger
        if (Trigger.isBefore)
        {
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();
            
            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete)
            {
                for (SObject so : Trigger.old)
                {
                    handler.beforeDelete(so);
                }
            }
            // Iterate through the records to be inserted passing them to the handler.
            else if (Trigger.isInsert)
            {
                for (SObject so : Trigger.new)
                {
                    handler.beforeInsert(so);
                }
            }
            // Iterate through the records to be updated passing them to the handler.
            else if (Trigger.isUpdate)
            {
                for (SObject so : Trigger.old)
                {
                    handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }
        else
        {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();
            
            // Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete)
            {
                for (SObject so : Trigger.old)
                {
                    handler.afterDelete(so);
                }
            }
            // Iterate through the records inserted passing them to the handler.
            else if (Trigger.isInsert)
            {
                for (SObject so : Trigger.new)
                {
                    handler.afterInsert(so);
                }
            }
            // Iterate through the records updated passing them to the handler.
            else if (Trigger.isUpdate)
            {
                for (SObject so : Trigger.old)
                {
                    handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }
        
        // Perform any post processing
        handler.andFinally();
    }

    /**
     * private static method to get the appropriate handler for the object type.
     * Modify this method to add any additional handlers.
     *
     * Arguments:   TriggerConfig__c config - Object type tolocate (SObject.sObjectType)
     *
     * Returns:     ITrigger - A trigger handler if one exists or null.
     */
    private static ITrigger getHandler(TriggerConfig__c config)
    {
        ITrigger handler;

        if(String.isNotBlank(config.ApexHandler__c)){
            // Retrieve type for trigger handler class name
            Type t = Type.forName(config.ApexHandler__c);

            Object typeInstance = t.newInstance();
            
            // Instantiate handler if handler is of type ITrigger
            if(t != null && typeInstance instanceof ITrigger){
                handler = (ITrigger) typeInstance;
            }
            else{
                // send null handler to skip execution
                system.debug('WARNING: Handler ' + config.ApexHandler__c + ' for Sobject ' + config.name + ' does not inherit IHandler interface');
            }
        }

        return handler; 
    }
}