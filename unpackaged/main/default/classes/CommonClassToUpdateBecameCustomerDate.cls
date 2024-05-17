/**********************************************************
Class: CommonClassToUpdateBecameCustomerDate
LastModifiedBy: Cloud Connex 04/06/2023
Description: Common class to get accounts which need to update Account.Became_a_Customer_Date__c
TestClass: 
***********************************************************/
public class CommonClassToUpdateBecameCustomerDate {
    
    public static Map<Id,Account> getAccountsToUpdateBecameCustomer(set<Id> theUPAcntSet, String theSobjectType){
        List<Account> theHiearchyAccountsList = new List<Account>();
        Map<Id, List<Account>> theUPWithChildAccountsMap = new Map<Id, List<Account>>();
        Map<Id,DateTime> theUltimateParentWithDateTimeMap = new Map<Id,DateTime>();
        Map<Id,Account> theAcntMapsToUpdate = new Map<Id,Account>();
        
        //Fetch all the Accounts with Entire Hierarchy
        theHiearchyAccountsList = [SELECT Id, Ultimate_Parent__c, Ultimate_Parent__r.Churned_Customer_Date__c, Churned_Customer_Date__c, Became_a_Customer_Date__c, Ultimate_Parent__r.Became_a_Customer_Date__c FROM Account WHERE Ultimate_Parent__c IN: theUPAcntSet OR Id IN: theUPAcntSet];
        
        for(Account theAcnt : theHiearchyAccountsList){
            
            if(theAcnt.Ultimate_Parent__c == null){
                //Store the Became_a_Customer_Date__c value of Ultimate Parent
                if(!theUltimateParentWithDateTimeMap.containskey(theAcnt.Id) && theAcnt.Became_a_Customer_Date__c != null && (theSobjectType == 'Opportunity' || theSobjectType == 'Account')) {
                    theUltimateParentWithDateTimeMap.put(theAcnt.Id, theAcnt.Became_a_Customer_Date__c);
                }else if(!theUltimateParentWithDateTimeMap.containskey(theAcnt.Id) && theAcnt.Churned_Customer_Date__c != null && theSobjectType == 'Case'){
                    theUltimateParentWithDateTimeMap.put(theAcnt.Id, theAcnt.Churned_Customer_Date__c);
                }
                
                //Store the Ultimate Parent
                if(!theUPWithChildAccountsMap.containskey(theAcnt.Id)){
                    theUPWithChildAccountsMap.put(theAcnt.Id, new List<Account>{theAcnt});
                }else{
                    theUPWithChildAccountsMap.get(theAcnt.Id).add(theAcnt);
                }
            }else{
                
                //Check if the Ultimate Parent Became_a_Customer_Date__c is null, if null then Store the Oldest date of Childs record in Hierarchy
                if((theSobjectType == 'Opportunity' || theSobjectType == 'Account') && theAcnt.Ultimate_Parent__r.Became_a_Customer_Date__c == null){
                    if(!theUltimateParentWithDateTimeMap.containskey(theAcnt.Ultimate_Parent__c)) {
                        theUltimateParentWithDateTimeMap.put(theAcnt.Ultimate_Parent__c, theAcnt.Became_a_Customer_Date__c);
                    }else if((theUltimateParentWithDateTimeMap.get(theAcnt.Ultimate_Parent__c) == null) || (theUltimateParentWithDateTimeMap.get(theAcnt.Ultimate_Parent__c) > theAcnt.Became_a_Customer_Date__c)){
                        theUltimateParentWithDateTimeMap.put(theAcnt.Ultimate_Parent__c, theAcnt.Became_a_Customer_Date__c);
                    }
                }else if(theSobjectType == 'Case' && theAcnt.Ultimate_Parent__r.Churned_Customer_Date__c == null){
                    if(!theUltimateParentWithDateTimeMap.containskey(theAcnt.Ultimate_Parent__c)) {
                        theUltimateParentWithDateTimeMap.put(theAcnt.Ultimate_Parent__c, theAcnt.Churned_Customer_Date__c);
                    }else if((theUltimateParentWithDateTimeMap.get(theAcnt.Ultimate_Parent__c) == null) || (theUltimateParentWithDateTimeMap.get(theAcnt.Ultimate_Parent__c) > theAcnt.Churned_Customer_Date__c)){
                        theUltimateParentWithDateTimeMap.put(theAcnt.Ultimate_Parent__c, theAcnt.Churned_Customer_Date__c);
                    }
                }
                
                //Store all the child records with Ultimate Parent
                if(!theUPWithChildAccountsMap.containskey(theAcnt.Ultimate_Parent__c)){
                    theUPWithChildAccountsMap.put(theAcnt.Ultimate_Parent__c, new List<Account>{theAcnt});
                }else{
                    theUPWithChildAccountsMap.get(theAcnt.Ultimate_Parent__c).add(theAcnt);
                }
                
            }
            
        }
        
        //Then updates entire Hierarchy with the Child records oldest "Became_a_Customer_Date__c" or UP's "Became_a_Customer_Date__c" 
        for(String theUPId : theUltimateParentWithDateTimeMap.keyset()){
            for(Account theHiearchyAcnt : theUPWithChildAccountsMap.get(theUPId)){
                if(theHiearchyAcnt.Became_a_Customer_Date__c == null && (theSobjectType == 'Opportunity' || theSobjectType == 'Account')){
                    theHiearchyAcnt.Became_a_Customer_Date__c = theUltimateParentWithDateTimeMap.get(theUPId);
                }else if(theHiearchyAcnt.Churned_Customer_Date__c == null && theSobjectType == 'Case'){
                    theHiearchyAcnt.Churned_Customer_Date__c = theUltimateParentWithDateTimeMap.get(theUPId);
                }
                theAcntMapsToUpdate.put(theHiearchyAcnt.Id,theHiearchyAcnt);
            }
        }
        
        return theAcntMapsToUpdate;
        
    }
}