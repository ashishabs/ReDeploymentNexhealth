/**********************************************************
Class: AccountRollupsLwcController 
LastModifiedBy: Cloud Connex 04/20/2023
Description: Controller class of accountRollupsLWC 
TestClass : AccountRollupsLwcControllerTest
***********************************************************/
public with sharing class AccountRollupsLwcController {
    
    @AuraEnabled(cacheable=true)
    public static WrapperForHierarchyDetails fetchHierarchyDetails(String recordId) {
        
        Account theCurrentAccount = [SELECT Id, Hierarchy_Level__c, Name, ParentId, Ultimate_Parent__c, Account_Risk_Level__c, Type, (SELECT Id FROM Cases WHERE Status != 'Closed' AND RecordTypeId =: Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId()) FROM Account Where Id = :recordId];
        
        List<Account> theHierarchyAccounts;
        if(theCurrentAccount.Ultimate_Parent__c != null){
            //get Child Hierarchy of Ultimate Parent Account with cases
            theHierarchyAccounts = [SELECT Id, Ultimate_Parent__c, Name, ParentId, Account_Risk_Level__c, Type, (SELECT Id FROM Cases WHERE Status != 'Closed' AND RecordTypeId =: Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId()) FROM Account WHERE (Ultimate_Parent__c =: theCurrentAccount.Ultimate_Parent__c OR Id =: theCurrentAccount.Ultimate_Parent__c) AND Id != :theCurrentAccount.Id];
        }else{
            //get Current Account Details with cases if no Hierarchy 
            theHierarchyAccounts = [SELECT Id, Ultimate_Parent__c, Name, ParentId, Account_Risk_Level__c, Type, (SELECT Id FROM Cases WHERE Status != 'Closed' AND RecordTypeId =: Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId()) FROM Account WHERE Ultimate_Parent__c =: theCurrentAccount.Id AND Id != :theCurrentAccount.Id];
        }
                
        theHierarchyAccounts.add(theCurrentAccount);

        //Get Hiearachy Tier Level from Ultimate Parent
        Map<Id,Integer> theAcntWithTierLevelMap = new Map<Id,Integer>();
        if(theCurrentAccount.Ultimate_Parent__c != null){
            theAcntWithTierLevelMap.put(theCurrentAccount.Ultimate_Parent__c, 1);
           getHiearachyTierLevelFromUP(new List<String>{theCurrentAccount.Ultimate_Parent__c}, 1, theAcntWithTierLevelMap);
        }else{
           theAcntWithTierLevelMap.put(theCurrentAccount.Id, 1);
           getHiearachyTierLevelFromUP(new List<String>{theCurrentAccount.Id}, 1,theAcntWithTierLevelMap);
        } 
        
        Integer theRiskLocation = 0;
        Integer theOpenSupportCases = 0;
        Integer thePracticeLocationCount = 0;
        for (Account theAcnt : theHierarchyAccounts) {
            //Number of open support cases in hierarchy
            theOpenSupportCases = theOpenSupportCases + theAcnt.cases.size();
            
            //# At Risk Locations in Hierarchy
            if(theAcnt.Account_Risk_Level__c != 'Low' && theAcnt.Account_Risk_Level__c != null){
                theRiskLocation = theRiskLocation + 1;
            }
            
            //Number of Accounts where type = Practice Location
            if(theAcnt.Type == 'Practice Location'){
                thePracticeLocationCount = thePracticeLocationCount + 1;
            }
            
        }
        
        //Store data to Wrapper class
        WrapperForHierarchyDetails theWrap = new WrapperForHierarchyDetails();
        theWrap.RiskLocationCountApex = theRiskLocation;
        theWrap.OpenSupportCasesCountApex = theOpenSupportCases;
        theWrap.PracticeLocationCountApex = thePracticeLocationCount;
        theWrap.CurrentHiearchyTierLevel = theAcntWithTierLevelMap.get(theCurrentAccount.Id);
        return theWrap;
        
    }
    
    public static void getHiearachyTierLevelFromUP(List<String> theParentIdList, Integer theAccountTierLevel, Map<Id,Integer> theAcntWithTierLevelMap){
        String theQuery;
        theQuery = 'SELECT Id, Name, ParentId FROM Account WHERE ParentId IN : theParentIdList';
        
        List<Account> theParentAcntList = Database.query(theQuery);
        theAccountTierLevel =  theAccountTierLevel + 1;
        if(theParentAcntList.size() > 0){
            theParentIdList.clear();
            Account theAcnt;
            for(Integer i = 0; i < theParentAcntList.size(); i++ ) { 
                theAcnt = theParentAcntList.get(i);
                theParentIdList.add(theAcnt.Id);
                
                // create the map of AcntId with Tier level
                theAcntWithTierLevelMap.put(theAcnt.Id, theAccountTierLevel);
            }
            getHiearachyTierLevelFromUP(theParentIdList, theAccountTierLevel, theAcntWithTierLevelMap);
        }	
                
    }
    
    public class WrapperForHierarchyDetails{
        @AuraEnabled
        public Decimal CurrentHiearchyTierLevel{get;set;}
        @AuraEnabled
        public Integer RiskLocationCountApex{get;set;}
        @AuraEnabled
        public Integer OpenSupportCasesCountApex{get;set;}
        @AuraEnabled
        public Integer PracticeLocationCountApex{get;set;}
    }
}