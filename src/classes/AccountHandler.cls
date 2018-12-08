/**
 * Sample Trigger Handler for Account
 */
public class AccountHandler implements ITrigger 
{ 
  
    public void bulkBefore(){
  		system.debug('--- bulkbEfore is called');      
    }
    
    public void bulkAfter(){
  		system.debug('--- bulkAfter is called');      
    }
    
    public void beforeInsert(SObject so){
  		system.debug('--- beforeInsert is called');      
    }
    public void beforeUpdate(SObject oldSo, SObject so){
  		system.debug('--- beforeUpdate is called');      
    }

    public void beforeDelete(SObject so){
  		system.debug('--- beforeDelete is called');      
    }

    public void afterInsert(SObject so){
  		system.debug('--- afterInsert is called');      
    }

    public void afterUpdate(SObject oldSo, SObject so){
  		system.debug('--- afterUpdate is called');      
    }

    public void afterDelete(SObject so){
  		system.debug('--- afterDelete is called');      
    }
  
    public void andFinally(){
        system.debug('--- andFinally called');      
    }
}