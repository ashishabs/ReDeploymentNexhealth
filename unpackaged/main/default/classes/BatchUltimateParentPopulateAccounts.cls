/**********************************************************
Class: BatchUltimateParentPopulateAccounts 
LastModifiedBy: Cloud connex 05/04/2023
Description: Batch class to populate the Hierarchy Level and Total Child Locations on Accounts Hiearchy
TestClass : BatchUltimateParentPopulateAccountsTest
***********************************************************/
public class BatchUltimateParentPopulateAccounts implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    
    String theQuery;
    public List<Account> theAllAccounts = new List<Account>();
    public BatchUltimateParentPopulateAccounts(String Query) {
        this.theQuery = Query;
    }
    
    public BatchUltimateParentPopulateAccounts() {
        this.theQuery = 'SELECT Id, Name, ParentId, Ultimate_Parent__c, Type, Hierarchy_Level__c, Hierarchy_Adjusted__c, Total_Child_Locations__c FROM Account WHERE Ultimate_Parent__c = null AND Hierarchy_Adjusted__c = true';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(theQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> theAccList) {
        
        UltimateParentPopulateAccounts populateAccounts = new UltimateParentPopulateAccounts(theAccList);
        populateAccounts.execute();
        
        theAllAccounts.addAll(theAccList);
        
    }
    
    public void finish(Database.BatchableContext BC){
        Map<Id,Account> theAcntUpdatesMap = new Map<Id,Account>();
        for(Account theAcnt: theAllAccounts){
            if(theAcnt.Hierarchy_Adjusted__c == true){
                theAcnt.Hierarchy_Adjusted__c = false;
                theAcntUpdatesMap.put(theAcnt.Id, theAcnt);
            }
        }
        
        update theAcntUpdatesMap.values();
    }
    
    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new BatchUltimateParentPopulateAccounts(), 200);
    }
    
}