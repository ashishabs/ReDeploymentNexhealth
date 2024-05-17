/**********************************************************
Class: CaseTriggerHandler
LastModifiedBy: Cloud Connex 04/11/2023
Description: handler class of CaseTrigger  
TestClass : CaseTriggerHandlerTest
***********************************************************/
public class CaseTriggerHandler {
    
    public static void stampAccountfieldsWithCases(List<Case> theCaseList, Map<Id,Case> theOldMap) {
        
        if((theOldMap == null && !CheckRecursive.isStampAccountfieldsWithCasesAfterInsert) || (theOldMap != null && !CheckRecursive.isStampAccountfieldsWithCasesAfterUpdate)) {
            
            if(theOldMap == null){
                CheckRecursive.isStampAccountfieldsWithCasesAfterInsert = true;
            }else if(theOldMap != null){
                CheckRecursive.isStampAccountfieldsWithCasesAfterUpdate = true;
            }
            
            Map<Id,Account> theAccountMapForUpdate = new Map<Id,Account>();
            Map<Id,Decimal> theSaaSContractionAmountForAcnt = new Map<Id,Decimal>();
            Map<Id,Decimal> theSaaSCancellationRequestCount = new Map<Id,Decimal>();
            Set<Id> theAccountIds = new Set<Id>();
            
            for(Case theCase : theCaseList) {
                theAccountIds.add(theCase.AccountId);
            }
            
            Id theChurnRecordid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Churn').getRecordTypeId();
            List<Account> theAccountWithCases = [SELECT Id, Number_of_Locations_from_Opportunities__c, (SELECT Id, CreatedDate, RecordTypeId, AccountId, ClosedDate, Number_of_locations_contracted__c, Churn_Type__c, Status FROM Cases) FROM Account WHERE Id IN: theAccountIds];
            
            for(Account theAcnt : theAccountWithCases) {
                
                Boolean IsAcntUpdate = false;
                DateTime theSaaSChurnRequest;
                DateTime theSaaSCancelledAt;
                List<DateTime> theDateTimeList = new List<DateTime>();
                for(Case theCase : theAcnt.Cases) {
                    if(theCase.RecordTypeId == theChurnRecordid && theCase.Churn_Type__c == 'Contraction' && theCase.Status == 'closed_saved') {
                        theDateTimeList.add(theCase.CreatedDate);
                        
                        if(!theSaaSContractionAmountForAcnt.containsKey(theAcnt.Id) && theCase.Number_of_locations_contracted__c != null) {
                            theSaaSContractionAmountForAcnt.put(theAcnt.Id, theCase.Number_of_locations_contracted__c);
                        }else{
                            if(theCase.Number_of_locations_contracted__c != null){
                                theSaaSContractionAmountForAcnt.put(theAcnt.Id,theSaaSContractionAmountForAcnt.get(theAcnt.Id) + theCase.Number_of_locations_contracted__c);
                            }
                        }
                    }
                    
                    if(theCase.RecordTypeId == theChurnRecordid && theCase.Churn_Type__c == 'Cancellation' && theCase.Status == 'closed_saved'){
                        theSaaSChurnRequest = theCase.CreatedDate;
                        theSaaSCancelledAt = theCase.ClosedDate;
                        
                        if(!theSaaSCancellationRequestCount.containsKey(theAcnt.Id)) {
                            theSaaSCancellationRequestCount.put(theAcnt.Id, 1);
                        }else{
                            theSaaSCancellationRequestCount.put(theAcnt.Id,theSaaSCancellationRequestCount.get(theAcnt.Id) + 1);
                        }
                    }
                }
                theDateTimeList.sort();
                if(theDateTimeList.size() > 0){
                    theAcnt.First_SaaS_Contraction_At__c = theDateTimeList[0];
                    theAcnt.Total_SaaS_Contractions__c = theDateTimeList.size();
                    IsAcntUpdate = true;
                }
                if(theDateTimeList.size() > 1) {
                    theAcnt.Last_SaaS_Contraction_At__c = theDateTimeList[theDateTimeList.size() - 1];
                    IsAcntUpdate = true;
                }
                
                if(theSaaSContractionAmountForAcnt.containsKey(theAcnt.Id)) {
                    if(theAcnt.Number_of_Locations_from_Opportunities__c != null){
                        theAcnt.SaaS_Contraction_Amount_licenses__c = theAcnt.Number_of_Locations_from_Opportunities__c - theSaaSContractionAmountForAcnt.get(theAcnt.Id);
                        IsAcntUpdate = true;
                    }else{
                        theAcnt.SaaS_Contraction_Amount_licenses__c = 0 - theSaaSContractionAmountForAcnt.get(theAcnt.Id);
                        IsAcntUpdate = true;
                    }
                }
                
                if(theSaaSChurnRequest != null) {
                    theAcnt.SaaS_Churn_Requested_At__c = theSaaSChurnRequest;
                    IsAcntUpdate = true;
                }
                
                if(theSaaSCancelledAt != null) {
                    theAcnt.SaaS_Cancelled_At__c = theSaaSCancelledAt;
                    IsAcntUpdate = true;
                }
                
                if(theSaaSCancellationRequestCount.containsKey(theAcnt.Id)) {
                    theAcnt.SaaS_Churn_Request_Count__c = theSaaSCancellationRequestCount.get(theAcnt.Id);
                    IsAcntUpdate = true;
                }
                
                if(IsAcntUpdate)  theAccountMapForUpdate.put(theAcnt.Id, theAcnt);
            }
            
            if(!theAccountMapForUpdate.isEmpty()) {
                update theAccountMapForUpdate.values();
            }
        }
    }
    
    public static void unlockCaseRecordFromApproval(List<Case> theCaseList) {
        system.enqueueJob(new CaseTriggerHandler.unlockCaseRecordQueueable(theCaseList));
    }
    
    public class unlockCaseRecordQueueable implements Queueable {
        public List<Case> theCaseList;
        
        public unlockCaseRecordQueueable(List<Case> CaseList) {
            this.theCaseList = CaseList;
        }
        
        public void execute (QueueableContext context) { 
            
            for(Case theCase : theCaseList) {
                if(Approval.isLocked(theCase.Id)) {
                    Approval.UnlockResult unlockResult = Approval.unlock(theCase.Id);
                } 
            }
            
        }
    }
    
    public static void updateBusinessHoursCheckbox(List<Case> theCaseList) {
        
        List<BusinessHours> theOfficeBHList = [SELECT Id FROM BusinessHours WHERE IsDefault = true Limit 1];
        
        if(!theOfficeBHList.isEmpty()) {
            for(Case theCase : theCaseList) {
                
                theCase.Opened_During_Business_Hours__c = BusinessHours.isWithin(theOfficeBHList[0].Id, System.now());
                
            }    
        } 
    }
    
    public static void callCustomerLifecycleQueuable(List<Case> theCaseList) { 
        
        Set<Id> theAcntIdsSet = new Set<Id>();
        Set<Id> theUPAcntSet = new Set<Id>();
        Id theChurnRecordid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Churn').getRecordTypeId();
        
        for(Case theCase : theCaseList) {
            
            if(theCase.AccountId != null && theCase.IsClosed && theCase.RecordTypeId == theChurnRecordid) {
                theAcntIdsSet.add(theCase.AccountId);
            }
            
        }
        
        for(Account rec : [SELECT Id, Ultimate_Parent__c, Churned_Customer_Date__c FROM Account WHERE Id IN: theAcntIdsSet]){
            if(rec.Ultimate_Parent__c != null){
                theUPAcntSet.add(rec.Ultimate_Parent__c);
            }
        }        
        
        if(!theUPAcntSet.isEmpty()) {
            System.enqueueJob(new CustomerLifecycleQueueable(theUPAcntSet, 'Case'));
        }
        
    }
}