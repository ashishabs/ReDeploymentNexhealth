/**********************************************************
Class: OpportunityTriggerhandler
LastModifiedBy: Cloud Connex 07/25/2023
Description: handler class of OpportunityTrigger.
Test Class: OpportunityTriggerhandlerTest
***********************************************************/
public class OpportunityTriggerhandler {
    
    public static void updateAccountAndContactsWithActiveDeveloperStatus(List<Opportunity> theOppList, Map<Id,Opportunity> theOldMap) { 
        
        if((theOldMap == null && !CheckRecursive.isUpdateAccountAndContactsWithActiveDeveloperStatusAfterInsert) || (theOldMap != null && !CheckRecursive.isUpdateAccountAndContactsWithActiveDeveloperStatusAfterUpdate && !CheckRecursive.isUpdateAccountAndContactsWithActiveDeveloperStatusAfterInsert)) {
            
            if(theOldMap == null){
                CheckRecursive.isUpdateAccountAndContactsWithActiveDeveloperStatusAfterInsert = true;
            }else if(theOldMap != null){
                CheckRecursive.isUpdateAccountAndContactsWithActiveDeveloperStatusAfterUpdate = true;
            }
            
            List<Id> theAccountIds = new List<Id>();
            List<Id> theContactIds = new List<Id>();
            Set<Id> theOppIds = new Set<Id>();
            Map<Id,Account> theAcntMapForUpdate = new Map<Id,Account>();
            Map<Id,Contact> theContactMapForUpdate = new Map<Id,Contact>();
            
            Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Developer').getRecordTypeId();
            
            for(Opportunity theOpp : theOppList) {
                
                if(theOpp.RecordTypeId == theDevRecordTypeId && theOpp.StageName == 'Closed Won') {
                    theOppIds.add(theOpp.Id);
                    if(theOpp.AccountId != null) {
                        theAccountIds.add(theOpp.AccountId);
                    }
                }
                
            }
            List<OpportunityContactRole> theOCRList = new List<OpportunityContactRole>();
            if(!theOppIds.IsEmpty()) {
                theOCRList = [SELECT Id, ContactId, OpportunityId FROM OpportunityContactRole WHERE OpportunityId IN: theOppIds];        
            }
            
            for(OpportunityContactRole theOCR : theOCRList) {
                
                if(theOCR.ContactId != null) {
                    theContactIds.add(theOCR.ContactId);
                }
                
            }
            
            for(Id theAcntId : theAccountIds) {
                
                Account theAcnt = new Account();
                theAcnt.Id = theAcntId;
                theAcnt.Developer_Status__c = 'Active';
                theAcntMapForUpdate.put(theAcntId, theAcnt);
                
            }
            
            for(Id theContId : theContactIds) {
                
                Contact theCont = new Contact();
                theCont.Id = theContId;
                theCont.Developer_Status__c = 'Active';
                theContactMapForUpdate.put(theContId, theCont);
                
            }
            
            if(!theAcntMapForUpdate.isEmpty()) update theAcntMapForUpdate.values();
            if(!theContactMapForUpdate.isEmpty()) update theContactMapForUpdate.values();
        }
    }
    
    public static void UpdateAccountRecordType(List<Opportunity> theOppList, Map<Id,Opportunity> theOldMap) {
        
        Set<Id> theAccountIds = new Set<Id>();
        Map<Id,Account> theAccountMapForUpdate = new Map<Id,Account>();
        List<String> theRecordTypeForCustomer = new List<String>{'Enterprise', 'API Access', 'New Business', 'Upsell'};
            List<String> theRecordTypeForPartner = new List<String>{'Reseller Partnership', 'Referral Partnership'};   
                
                for(Opportunity theOpp : theOppList) {
                    
                    if(String.isNotEmpty(theOpp.AccountId)) {
                        theAccountIds.add(theOpp.AccountId);
                    }
                    
                }
        List<Account> theAllAccountsList = new List<Account>();
        if(!theAccountIds.isEmpty()){
            theAllAccountsList = [SELECT Id, RecordTypeId, RecordType.Name, (SELECT Id, LastModifiedDate, StageName, RecordTypeId, RecordType.Name FROM Opportunities) FROM Account WHERE Id IN: theAccountIds];
        }
        
        for(Account theAcnt : theAllAccountsList) {
            
            Boolean theAcntForUpdate = false;
            String theRecordType;
            
            for(Opportunity theOpp : theAcnt.Opportunities) {
                if(theOpp.StageName == 'Closed Won' || theOpp.StageName == 'Install Complete') {
                    
                    if(theOpp.RecordType.Name == 'Developer'){
                        theRecordType = 'Developer';
                    }
                    
                    if(theRecordTypeForCustomer.contains(theOpp.RecordType.Name)) {
                        theRecordType = 'Customer';
                    }
                    
                    if(theRecordTypeForPartner.contains(theOpp.RecordType.Name) && theRecordType != 'Customer') {
                        theRecordType = 'Partner';
                    }
                }else if(theRecordType != 'Customer' && theRecordType != 'Partner') {
                    theRecordType = 'Prospect';
                }
                
            }
            if(theRecordType == 'Developer' && theAcnt.RecordTypeId != Schema.SObjectType.Account.getRecordTypeInfosByName().get('Developer').getRecordTypeId()) {
                theAcnt.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Developer').getRecordTypeId();
                theAcntForUpdate = true;
            }else if(theRecordType == 'Customer' && theAcnt.RecordTypeId != Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId()) {
                theAcnt.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
                theAcntForUpdate = true;
            }else if(theRecordType == 'Partner' && theAcnt.RecordTypeId != Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId()) {
                theAcnt.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
                theAcntForUpdate = true;
            }else if(theRecordType == 'Prospect' && theAcnt.RecordTypeId != Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId()) {
                theAcnt.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
                theAcntForUpdate = true;
            }
            
            if(theAcntForUpdate)  theAccountMapForUpdate.put(theAcnt.Id,theAcnt);
            
        }
        
        if(!theAccountMapForUpdate.isEmpty())  update theAccountMapForUpdate.values();
    }
    
    public static void updateOCRContactDate(List<Opportunity> theNewOppList, Map<Id,Opportunity> theOldMap) {
        
        Set<Id> theStageChangeOppSet = new Set<Id>();
        for(Opportunity theOpp : theNewOppList) {
            
            if((theOpp.StageName == 'Closed Lost' || theOpp.StageName == 'Closed Won') && theOldMap != null && theOldMap.get(theOpp.Id).StageName != theOpp.StageName) {
                theStageChangeOppSet.add(theOpp.Id);
            }
            
        }
        Map<Id, Contact> theContactForUpdateMap = new  Map<Id, Contact>();
        if(!theStageChangeOppSet.isEmpty()){
            List<Opportunity> theOppList = [SELECT Id, CreatedDate, CloseDate, LastModifiedDate, StageName, RecordType.Name, Loss_Reason__c, Win_Reason__c, (SELECT Id, Role, ContactId, Contact.Closed_Lost_Opportunity_date__c FROM OpportunityContactRoles WHERE ContactId != null AND IsPrimary = True) FROM Opportunity WHERE Id IN: theStageChangeOppSet ORDER BY LastModifiedDate DESC];
            
            Set<Id> theIncludedContactIds = new Set<Id>();
            for(Opportunity theOpp : theOppList) {
                
                for(OpportunityContactRole theOCR : theOpp.OpportunityContactRoles) {
                    
                    if(!theIncludedContactIds.contains(theOCR.ContactId)) {
                        theIncludedContactIds.add(theOCR.ContactId);
                        if(theOpp.StageName == 'Closed Lost' && theOCR.Contact.Closed_Lost_Opportunity_date__c != System.Today()) {
                            Contact theCon = new Contact();
                            theCon.Id = theOCR.ContactId;
                            theCon.Closed_Lost_Opportunity_date__c = System.Today();
                            theCon.Last_Opportunity_Record_Type__c = theOpp.RecordType.Name;
                            theCon.Last_Opportunity_Close_Date__c = theOpp.CloseDate;
                            theCon.Last_Opportunity_Closed_Lost_Reason__c = theOpp.loss_reason__c;
                            theCon.Last_Opportunity_Closed_Won_Reason__c = '';
                            theCon.Last_Opportunity_Contact_Role__c = theOCR.Role;
                            theCon.Last_Opportunity_Created_Date__c = theOpp.CreatedDate;
                            theCon.Last_Opportunity_Stage__c = theOpp.StageName;
                            theContactForUpdateMap.put(theCon.Id, theCon);
                        } else if(theOpp.StageName == 'Closed Won') {
                            Contact theCon = new Contact();
                            theCon.Id = theOCR.ContactId;
                            theCon.Closed_Lost_Opportunity_date__c = null;
                            theCon.Last_Opportunity_Record_Type__c = theOpp.RecordType.Name;
                            theCon.Last_Opportunity_Close_Date__c = theOpp.CloseDate;
                            theCon.Last_Opportunity_Closed_Won_Reason__c = theOpp.Win_Reason__c;
                            theCon.Last_Opportunity_Closed_Lost_Reason__c = '';
                            theCon.Last_Opportunity_Contact_Role__c = theOCR.Role;
                            theCon.Last_Opportunity_Created_Date__c = theOpp.CreatedDate;
                            theCon.Last_Opportunity_Stage__c = theOpp.StageName;
                            theContactForUpdateMap.put(theCon.Id, theCon);
                        }
                    }
                    
                }
                
            }
        }
        if(!theContactForUpdateMap.values().isEmpty()) update theContactForUpdateMap.values();
    }
    
    public static void updateAccountTimeStampFields(List<Opportunity> theOppList, Map<Id,Opportunity> theOldMap) { 
        if((theOldMap == null && !CheckRecursive.isupdateAccountTimeStampFieldsAfterInsert) || (theOldMap != null && !CheckRecursive.isupdateAccountTimeStampFieldsAfterUpdate && !CheckRecursive.isupdateAccountTimeStampFieldsAfterInsert)) {
            
            if(theOldMap == null){
                CheckRecursive.isupdateAccountTimeStampFieldsAfterInsert = true;
            }else if(theOldMap != null){
                CheckRecursive.isupdateAccountTimeStampFieldsAfterUpdate = true;
            }
            
            if(!System.isQueueable()) {
                // system.debug('Inside Queueable');
                OpportunityTriggerhandler.RollupsForAccountFieldsQueueable theQueueablejob = new OpportunityTriggerhandler.RollupsForAccountFieldsQueueable(theOppList);  
                system.enqueueJob(theQueueablejob);  
            }else{
                OpportunityTriggerhandler.commonMethodToCallQueueableLogic(theOppList);
            }
        }
        
    }
    
    public static void commonMethodToCallQueueableLogic(List<Opportunity> theOppList) {
        
        List<Account> theAccountForUpdateList = new List<Account>();
        Set<Id> theAccountIdsSet = new Set<Id>();
        
        for(Opportunity theOpp : theOppList) {
            
            if(theOpp.AccountId != null) {
                theAccountIdsSet.add(theOpp.AccountId);
            }
            
        }
        
        List<Account> theAccountWithOppsList = [SELECT Id, (SELECT Id, AccountId, StageName, RecordType.Name, Close_Date_Timestamp__c, CreatedDate FROM Opportunities) FROM Account WHERE Id IN : theAccountIdsSet];
        
        List<Account_Opportunity_Rollup_Field__mdt> theMDList = [SELECT Id, Opportunity_field__c, Account_field__c, Operation__c, Record_Type_Name__c  FROM Account_Opportunity_Rollup_Field__mdt];
        
        for(Account theAcnt : theAccountWithOppsList) {
            
            Account theAcc = GenericRollupBatchUpdate.getUpdatedRollup(theAcnt.Id, theAcnt.Opportunities, theMDList);
            if(theAcc != null) theAccountForUpdateList.add(theAcc);
            
        }
        
        if(!theAccountForUpdateList.isEmpty()) update theAccountForUpdateList;
        
    }
    
    public class RollupsForAccountFieldsQueueable implements Queueable {
        
        public List<Opportunity> theOppList;
        
        public RollupsForAccountFieldsQueueable(List<Opportunity> theOppsList) {
            this.theOppList = theOppsList;
        }
        
        public void execute(QueueableContext context) {
            
            OpportunityTriggerhandler.commonMethodToCallQueueableLogic(theOppList);
            
        }
        
    }
    
    public static void OppInstallCompleteEmailNotification(List<Opportunity> theOppList, Map<Id,Opportunity> theOldMap) {
        
        Id theApiAccessRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API Access').getRecordTypeId();
        Set<Id> theAccIdSet = new Set<Id>();
        Set<Id> theContactIdSet = new Set<Id>();
        Map<Id, Contact> theRefContactMap = new Map<Id, Contact>();
        
        if((theOldMap == null && !CheckRecursive.isOppInstallCompleteEmailNotificationBeforeInsert) || (theOldMap != null && !CheckRecursive.isOppInstallCompleteEmailNotificationBeforeUpdate)) {
            
            if(theOldMap == null){
                CheckRecursive.isOppInstallCompleteEmailNotificationBeforeInsert = true;
            }else if(theOldMap != null){
                CheckRecursive.isOppInstallCompleteEmailNotificationBeforeUpdate = true;
            }
            
            for(Opportunity theOpp : theOppList) {
                
                if(theOpp.Referral_Contact__c != null) theContactIdSet.add(theOpp.Referral_Contact__c);
                if(theOpp.referral_source__c != null && theOpp.RecordTypeId == theApiAccessRecordType && theOpp.StageName == 'Install Complete' && (theOldMap == null || theOpp.StageName != theOldMap.get(theOpp.Id).StageName) ) {
                    theAccIdSet.add(theOpp.referral_source__c);
                }
                
            } 
            
            Map<Id, Account> theAccountMap = new Map<Id, Account>([SELECT Id, Name, (SELECT Id, Email, Name FROM Contacts WHERE Send_API_Install_Updates__c = TRUE AND Email != NULL) FROM Account WHERE Id IN: theAccIdSet]);
            
            theRefContactMap = new Map<Id, Contact>([SELECT Id, Name, Email FROM Contact WHERE Id IN: theContactIdSet AND Email = NULL]);
            
            for(Opportunity theOpp : theOppList) {
                
                if( (theOpp.Referral_Contact__c != null || theOpp.referral_source__c != null) && theOpp.RecordTypeId == theApiAccessRecordType && theOpp.StageName == 'Install Complete' && (theOldMap == null || theOpp.StageName != theOldMap.get(theOpp.Id).StageName) ) {
                    
                    if( theRefContactMap.ContainsKey(theOpp.Referral_Contact__c) && theAccountMap.ContainsKey(theOpp.referral_source__c) && theAccountMap.get(theOpp.referral_source__c).Contacts.size() == 0) {
                        String theError = 'No contacts with "Send API Install Updates" were found on the Referral Source Account. Please add a contact in order to send the Install Complete email.';
                        theOpp.addError(theError);
                    } 
                    
                }
                
            }
            
        }
        
    }    
    
    public static void CreateTaskFromOpportunity(List<Opportunity> theOppList, Map<Id, Opportunity> theOldMap) {
        
        Id theApiAccessRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API Access').getRecordTypeId();
        Set<Id> theAccIdSet = new Set<Id>();
        Map<Id, List<String>> theAcntIdContactEmailMap = new Map<Id, List<String>>();
        Map<String,EmailTemplate> theEmailTemplateMap = new Map<String,EmailTemplate>();
        List<Task> theTaskListInsert = New List<Task>();
        Set<Id> theContactIdSet = new Set<Id>();
        Map<Id, Contact> theRefContactMap = new Map<Id, Contact>();
        Set<Id> theOppIdSet = new Set<Id>();
        Map<Id, Opportunity> theOppQueryMap = new Map<Id, Opportunity>();
        Map<Id, Messaging.SingleEmailMessage> theOppIdtAndMailList = new Map<Id, Messaging.SingleEmailMessage>();
        
        if((theOldMap == null && !CheckRecursive.isCreateTaskFromOpportunityAfterInsert) || (theOldMap != null && !CheckRecursive.isCreateTaskFromOpportunityAfterUpdate)) {
            
            if(theOldMap == null){
                CheckRecursive.isCreateTaskFromOpportunityAfterInsert = true;
            }else if(theOldMap != null){
                CheckRecursive.isCreateTaskFromOpportunityAfterUpdate = true;
            }
            
            List<EmailTemplate> theEmailTemplateList = [SELECT Id, Subject, Body, Name FROM EmailTemplate WHERE Name = 'iBookTemplate' OR Name = 'SmileDirectClubTemplate' OR Name = 'TrueLarkTemplate' OR Name = 'anythingElseTemplate'];
            for(EmailTemplate theTemplate : theEmailTemplateList){
                theEmailTemplateMap.put(theTemplate.Name,theTemplate);
            }
            
            for(Opportunity theOpp : theOppList) {
                
                if(theOpp.Referral_Contact__c != null) theContactIdSet.add(theOpp.Referral_Contact__c);
                if(theOpp.Do_not_send_API_Install_Completed_Email__c == False && theOpp.referral_source__c != null && theOpp.RecordTypeId == theApiAccessRecordType && theOpp.StageName == 'Install Complete' && (theOldMap == null || theOpp.StageName != theOldMap.get(theOpp.Id).StageName) ) {
                    theAccIdSet.add(theOpp.referral_source__c);
                }
                theOppIdSet.add(theOpp.Id);
                
            }     
            
            if(!theOppIdSet.isEmpty()) {
                theOppQueryMap = new Map<Id, Opportunity>([SELECT Id, Name, Owner.Name, Owner.Email FROM Opportunity WHERE Id IN: theOppIdSet]);
            }
            if(!theContactIdSet.isEmpty()) {
                theRefContactMap = new Map<Id, Contact>([SELECT Id, Name, Email FROM Contact WHERE Id IN: theContactIdSet AND Email != NULL]);
            }
            if(!theAccIdSet.isEmpty()) {
                Map<Id, Account> theAccountMap = new Map<Id, Account>([SELECT Id, Name, (SELECT Id, Email, Name FROM Contacts WHERE Send_API_Install_Updates__c = TRUE AND Email != NULL) FROM Account WHERE Id IN: theAccIdSet]);
                
                for(Id theAccId : theAccountMap.keySet()) {
                    for(Contact theCon : theAccountMap.get(theAccId).Contacts) {
                        if(!theAcntIdContactEmailMap.containsKey(theAccId)){
                            theAcntIdContactEmailMap.put(theAccId, new List<String>());
                        }
                        theAcntIdContactEmailMap.get(theAccId).add(theCon.Email);
                    }
                }
                
                for(Opportunity theOpp : theOppList) {
                    
                    List<String> theEmailList = new List<String>();
                    If(theAcntIdContactEmailMap.containskey(theOpp.referral_source__c)) theEmailList.addAll(theAcntIdContactEmailMap.get(theOpp.referral_source__c));
                    if(theRefContactMap.containskey(theOpp.Referral_Contact__c) && !theEmailList.contains(theRefContactMap.get(theOpp.Referral_Contact__c).Email)) theEmailList.add(theRefContactMap.get(theOpp.Referral_Contact__c).Email);
                    
                    if((theAccountMap.containskey(theOpp.referral_source__c) && theAccountMap.get(theOpp.referral_source__c).Contacts.size() != 0) || theOpp.Referral_Contact__c != null) {
                        if(theAccountMap.get(theOpp.referral_source__c).Name == 'iBook' && theAccountMap.get(theOpp.referral_source__c).Contacts.size() != 0) {
                            theOppIdtAndMailList.put(theOpp.Id, commonMethodToCreateEmailBody(theEmailTemplateMap.get('iBookTemplate').Id, theAccountMap.get(theOpp.referral_source__c).Contacts[0].Id, theOpp.Id, theEmailList, theOppQueryMap.get(theOpp.Id).Owner.Email, theOppQueryMap.get(theOpp.Id).Owner.Name));
                        }else if(theAccountMap.get(theOpp.referral_source__c).Name == 'Smile Direct Club' && theAccountMap.get(theOpp.referral_source__c).Contacts.size() != 0) {
                            theOppIdtAndMailList.put(theOpp.Id, commonMethodToCreateEmailBody(theEmailTemplateMap.get('SmileDirectClubTemplate').Id, theAccountMap.get(theOpp.referral_source__c).Contacts[0].Id, theOpp.Id, theEmailList, theOppQueryMap.get(theOpp.Id).Owner.Email, theOppQueryMap.get(theOpp.Id).Owner.Name));
                        }else if(theAccountMap.get(theOpp.referral_source__c).Name == 'TrueLark' && theAccountMap.get(theOpp.referral_source__c).Contacts.size() != 0) {
                            theOppIdtAndMailList.put(theOpp.Id, commonMethodToCreateEmailBody(theEmailTemplateMap.get('TrueLarkTemplate').Id, theAccountMap.get(theOpp.referral_source__c).Contacts[0].Id, theOpp.Id, theEmailList, theOppQueryMap.get(theOpp.Id).Owner.Email, theOppQueryMap.get(theOpp.Id).Owner.Name));
                        }else if(theAccountMap.get(theOpp.referral_source__c).Contacts.size() != 0){ 
                            theOppIdtAndMailList.put(theOpp.Id, commonMethodToCreateEmailBody(theEmailTemplateMap.get('anythingElseTemplate').Id, theAccountMap.get(theOpp.referral_source__c).Contacts[0].Id, theOpp.Id, theEmailList, theOppQueryMap.get(theOpp.Id).Owner.Email, theOppQueryMap.get(theOpp.Id).Owner.Name));
                        } else {
                            theOppIdtAndMailList.put(theOpp.Id, commonMethodToCreateEmailBody(theEmailTemplateMap.get('anythingElseTemplate').Id, theOpp.Referral_Contact__c, theOpp.Id, theEmailList, theOppQueryMap.get(theOpp.Id).Owner.Email, theOppQueryMap.get(theOpp.Id).Owner.Name));
                        }
                        
                        Task theTask = new Task();
                        theTask.Subject = 'Sent API Install Complete email';
                        theTask.Status = 'Completed';
                        theTask.Description = 'API Install Complete email Subject: ['+theOppIdtAndMailList.get(theOpp.Id).getSubject()+'] '+'\n Body: '+ theOppIdtAndMailList.get(theOpp.Id).getPlainTextBody(); 
                        theTask.WhatId = theOpp.Id;
                        theTask.ActivityDate = System.today();
                        theTaskListInsert.add(theTask);
                        
                    }
                    
                    if(!theTaskListInsert.isEmpty()) insert theTaskListInsert; 
                    if(!theOppIdtAndMailList.isEmpty()) {
                        List<Messaging.SendEmailResult> sendEmailResultList = Messaging.sendEmail(theOppIdtAndMailList.values());
                    } 
                }
            }
        }
        
    }
    
    public static Messaging.SingleEmailMessage commonMethodToCreateEmailBody(String theTemplateId, String theUserId, String theWhatId, List<String> theToAddressList, String theOppOwnerEmail, String theOppOwnerName) {
        
        Messaging.SingleEmailMessage theMail = Messaging.renderStoredEmailTemplate(theTemplateId, theUserId, theWhatId);
        String theEmailSubject = theMail.getSubject();
        String theEmailTextBody = theMail.getPlainTextBody();
        theMail.setSubject(theEmailSubject);
        theMail.setPlainTextBody(theEmailTextBody);
        theMail.setReplyTo(theOppOwnerEmail);
        theMail.setSenderDisplayName(theOppOwnerName);
        theMail.setToAddresses(theToAddressList);
        theMail.setSaveAsActivity(false);
        return theMail;
        
    }
    
    public static void callCustomerLifecycleQueuable(List<Opportunity> theOppList, Map<Id, Opportunity> theOldMap) { 
        List<Id> recTypeIds = new List<Id>();
        recTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId());
        recTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API Access').getRecordTypeId());
        recTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId());
        recTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Upsell').getRecordTypeId());
        
        Set<Id> theAcntIdsSet = new Set<Id>();
        
        //Get related Accounts
        for(Opportunity theOpp : theOppList) {
            
            if( 
                (recTypeIds.contains(theOpp.RecordTypeId)) &&
                theOpp.AccountId != null && 
                (theOpp.StageName == 'Closed Won' || theOpp.StageName == 'Install Complete') && 
                (theOldMap == null || (theOldMap != null && theOldMap.get(theOpp.Id).StageName != theOpp.StageName)) 
            ) {
                theAcntIdsSet.add(theOpp.AccountId);
            }
            
        }
        
        //Added By Ajith
        //Get Ultimate Parents 
        Set<Id> theUPAcntSet = new Set<Id>();
        for(Account rec : [SELECT Id, Ultimate_Parent__c, Became_a_Customer_Date__c FROM Account WHERE Id IN: theAcntIdsSet]){
            if(rec.Ultimate_Parent__c != null){
                theUPAcntSet.add(rec.Ultimate_Parent__c);
            }
        }
        
        if(!theUPAcntSet.isEmpty()) {
            System.enqueueJob(new CustomerLifecycleQueueable(theUPAcntSet, 'Opportunity'));
        }
    }
    
    public static void checkandAddErrorOnUpsellOpportunity(List<Opportunity> theOppList) {
        
        Set<Id> theAccIdSet = new Set<Id>();
        Id theNewBusinessRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Id theEnterPriseRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        
        for(Opportunity theOpp : theOppList) {
            if(theOpp.AccountId != null && theOpp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Upsell').getRecordTypeId()) {
                theAccIdSet.add(theOpp.AccountId);
            }
        } 
        
        if(!theAccIdSet.isEmpty()) {
            
            Map<Id, Account> theAccountMap = new Map<Id, Account>([SELECT Id, (SELECT Id, StageName, AccountId FROM Opportunities WHERE StageName =: 'Closed Won' AND (RecordTypeId =: theNewBusinessRecordType OR RecordTypeId =: theEnterPriseRecordType)) FROM Account WHERE Id IN: theAccIdSet]);
            
            for(Opportunity theOpp : theOppList) {
                if(theOpp.AccountId != null && theAccountMap.ContainsKey(theOpp.AccountId) && theAccountMap.get(theOpp.AccountId).Opportunities.size() == 0) {
                    theOpp.addError('Require a Closed-Won New Business/Enterprise Opportunity to create an Upsell Opportunity.');
                }
            } 
        }
        
    }
    
    public static void unlockOppRecordFromApproval(List<Opportunity> theOppList) {
      if(!System.isQueueable())  system.enqueueJob(new OpportunityTriggerHandler.unlockOppRecordQueueable(theOppList));
    }
    
    public class unlockOppRecordQueueable implements Queueable {
        public List<Opportunity> theOppList;
        
        public unlockOppRecordQueueable(List<Opportunity> theOppList) {
            this.theOppList = theOppList;
        }
        
        public void execute (QueueableContext context) { 
            
            for(Opportunity theOpp : theOppList) {
                if(Approval.isLocked(theOpp.Id)) {
                    Approval.UnlockResult unlockResult = Approval.unlock(theOpp.Id);
                } 
            }
            
        }
    }
    
}