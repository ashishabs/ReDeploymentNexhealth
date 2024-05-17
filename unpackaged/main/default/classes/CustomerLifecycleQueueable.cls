/**********************************************************
Class: CustomerLifecycleQueueable
LastModifiedBy: Cloud Connex 04/11/2023
Description: Queueable class for OpportunityTrigger
TestClass: 
***********************************************************/
public class CustomerLifecycleQueueable implements Queueable {
    
    private Set<Id> theUPAcntSet;
    private String theSobjectType;
    
    public CustomerLifecycleQueueable(Set<Id> theUPAcntSet, String theSobjectType) {
        this.theUPAcntSet = theUPAcntSet;
        this.theSobjectType = theSobjectType;
    }
    
    public void execute(QueueableContext context) {
        
        Map<Id,Account> theAcntUpdatesMap = CommonClassToUpdateBecameCustomerDate.getAccountsToUpdateBecameCustomer(theUPAcntSet,theSobjectType); 
        
        if(!theAcntUpdatesMap.isEmpty()){
            update theAcntUpdatesMap.values();
        }
    
    }
    
}