/**********************************************************
Class: AccountTriggerHandler 
LastModifiedBy: Bopsy 05/02/2023
Description: Handler class of AccountTrigger
TestClass : AccountTriggerHandlerTest
***********************************************************/
public class AccountTriggerHandler {
    
    public static void updateAccountUltimateParent(List<Account> theAcntList, Map<Id, Account> theOldMap) { 
        
        List<Account> theAcntListWithParent = new List<Account>();
        
        for(Account theAcnt : theAcntList) {
            if(theAcnt.ParentId != null && (theOldMap == null || (theOldMap != null && theOldMap.get(theAcnt.Id).ParentId != theAcnt.ParentId))){
                theAcntListWithParent.add(theAcnt);
            }
            
        }
        if(!theAcntListWithParent.isEmpty()) {
            System.enqueueJob(new UltimateParentQueueable(theAcntListWithParent));
        }
        
    }
    
}