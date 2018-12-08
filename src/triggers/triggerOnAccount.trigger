/*
 * Sample Code for Account Trigger
 */
trigger triggerOnAccount on Account (before insert, before update, before delete, after insert, after update, after delete) {
    TriggerFactory.initiateHandler(Account.sObjectType);
}