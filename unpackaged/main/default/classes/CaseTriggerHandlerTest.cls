/**********************************************************
Class: CaseTriggerHandlerTest
LastModifiedBy: Cloud Connex 04/12/2023
Description: This is Test class for the CaseTriggerHandler     
***********************************************************/
@istest
public class CaseTriggerHandlerTest {
    
    @testSetup
    public static void testSetup() {
        Account testAcc = new Account(Name='Test Account');  
        insert testAcc;
        
        Contact testContact = new Contact();
        testContact.LastName = 'testLastName';
        testContact.Email = 'testingtest@test.com';
        testContact.AccountId = testAcc.Id;
        insert testContact;
    }
    
    // These two methods commented because in CaseTriggerHandler logic needs "Contraction" value for Churn_Type__c field but this value is inactive.
    /* @isTest
public static void testNewBusinessOppDate() {  

Account testAcc = [SELECT Id FROM Account];
Contact testCon = [SELECT Id FROM Contact];

List<Case> testCasetoUpdate = new List<Case>();
Case testCase = new Case();
testCase.AccountId = testAcc.Id;
testCase.ContactId = testCon.Id;
testCase.Churn_Type__c = 'Contraction';
testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Churn').getRecordTypeId();
testCase.churn_reason_primary__c = 'Activation - Free Trial Expired';
testCasetoUpdate.add(testCase);

Case testCase1 = new Case();
testCase1.AccountId = testAcc.Id;
testCase1.ContactId = testCon.Id;
testCase1.Churn_Type__c = 'Contraction';
testCase1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Churn').getRecordTypeId();
testCase1.churn_reason_primary__c = 'Activation - Free Trial Expired';
testCasetoUpdate.add(testCase1);

Test.startTest();  
testCase.Status = 'closed_saved';
testCase1.Status = 'closed_saved';
insert testCasetoUpdate;
Test.stopTest(); 

Account testAssert = [SELECT Id, First_SaaS_Contraction_At__c, Last_SaaS_Contraction_At__c, Total_SaaS_Contractions__c FROM Account];

System.assertEquals(System.Today(), testAssert.First_SaaS_Contraction_At__c.Date());
System.assertEquals(System.Today(), testAssert.Last_SaaS_Contraction_At__c.Date());
system.assertEquals(2, testAssert.Total_SaaS_Contractions__c);

} */
    
    /* @isTest
public static void testSaaSContractionAmountLicense() {  

Account testAcc = [SELECT Id FROM Account];
Contact testCon = [SELECT Id FROM Contact];

Opportunity testOpp = new Opportunity();
testOpp.Name = 'test Opp';
testOpp.CloseDate = System.today().addDays(-10);
testOpp.AccountId = testAcc.Id;
testOpp.StageName = 'Requalify';
testOpp.number_of_locations__c = 3;
testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Developer').getRecordTypeId();
insert testOpp;

List<Case> testCasetoUpdate = new List<Case>();
Case testCase = new Case();
testCase.AccountId = testAcc.Id;
testCase.ContactId = testCon.Id;
testCase.Churn_Type__c = 'Contraction';
testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Churn').getRecordTypeId();
testCase.Number_of_locations_contracted__c = 1;
testCase.churn_reason_primary__c = 'Activation - Free Trial Expired';
testCasetoUpdate.add(testCase);

Case testCase1 = new Case();
testCase1.AccountId = testAcc.Id;
testCase1.ContactId = testCon.Id;
testCase1.Churn_Type__c = 'Contraction';
testCase1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Churn').getRecordTypeId();
testCase1.Number_of_locations_contracted__c = 1;
testCase1.churn_reason_primary__c = 'Activation - Free Trial Expired';
testCasetoUpdate.add(testCase1);

Test.startTest();  
testCase.Status = 'closed_saved';
testCase1.Status = 'closed_saved';
insert testCasetoUpdate;
Test.stopTest(); 

Account testAssert = [SELECT Id, Number_of_Locations_from_Opportunities__c, First_SaaS_Contraction_At__c, Last_SaaS_Contraction_At__c, Total_SaaS_Contractions__c, SaaS_Contraction_Amount_licenses__c FROM Account];

System.assertEquals(System.Today(), testAssert.First_SaaS_Contraction_At__c.Date());
System.assertEquals(System.Today(), testAssert.Last_SaaS_Contraction_At__c.Date());
system.assertEquals(2, testAssert.Total_SaaS_Contractions__c);
system.assertEquals(testAssert.Number_of_Locations_from_Opportunities__c - 2, testAssert.SaaS_Contraction_Amount_licenses__c);

}*/
    
    @isTest
    public static void testSaaSCancellationRequestedAt() {  
        
        Account testAcc = [SELECT Id FROM Account];
        Contact testCon = [SELECT Id FROM Contact];
        
        Case testCase = new Case();
        testCase.AccountId = testAcc.Id;
        testCase.ContactId = testCon.Id;
        testCase.Churn_Type__c = 'Cancellation';
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Churn').getRecordTypeId();
        testCase.Number_of_locations_contracted__c = 1;
        //testCase.churn_reason_primary__c = 'Activation - Free Trial Expired';
        
        Test.startTest();  
        testCase.Status = 'closed_saved';
        insert testCase;
        Test.stopTest(); 
        
        Account testAssert = [SELECT Id, SaaS_Churn_Requested_At__c, SaaS_Cancelled_At__c, SaaS_Churn_Request_Count__c FROM Account];
        
        System.assertEquals(System.Today(), testAssert.SaaS_Churn_Requested_At__c.Date());
        system.assertEquals(1, testAssert.SaaS_Churn_Request_Count__c);
        
    }
    
    public static void testReferralPartnershipCancelledAt(){
        
        Account testAcnt = [SELECT Id FROM Account];
        
        test.startTest();
        testAcnt.Referral_Partner_Lifecycle__c = 'Churned';
        update testAcnt;
        test.stopTest();
        
        //Assertion
        Account testAssert = [SELECT Id, Referral_Partnership_Churned_At__c FROM Account];
        system.assertEquals(system.now(), testAssert.Referral_Partnership_Churned_At__c);
        
    }
    
    public static void testResellerPartnershipCancelledAt(){
        
        Account testAcnt = [SELECT Id FROM Account];
        
        test.startTest();
        testAcnt.Reseller_Partner_Lifecycle__c = 'Churned';
        update testAcnt;
        test.stopTest();
        
        //Assertion
        Account testAssert = [SELECT Id, Reseller_Partnership_Churned_At__c FROM Account];
        system.assertEquals(system.now(), testAssert.Reseller_Partnership_Churned_At__c);
        
    }
    
    @isTest
    public static void updateBusinessHoursCheckbox() {
        
        List<Case> testCaseList = new List<Case>();
        Case testCase = new Case();
        testCase.Status='New';
        testCaseList.add(testCase);
        
        Case testCase1 = new Case();
        testCase1.Status='New';
        testCaseList.add(testCase1);
        
        Case testCase2 = new Case();
        testCase2.Status='New';
        testCaseList.add(testCase2);
        
        test.startTest();
        insert testCaseList;  
        test.stopTest();
        
        List<Case> testCaseAssertList = [SELECT Id, Opened_During_Business_Hours__c FROM Case];
        for(Case testCaseAssert : testCaseAssertList) {
            // This may vary on the business hours time.
            //system.assertEquals(true, testCaseAssert.Opened_During_Business_Hours__c);
            
        }
    }
    
    @isTest
    public static void testCaseUpdateCustomerDateFromultimateParent() { 
        
        List<Account> tier1 = new List<Account>();
        List<Account> tier2 = new List<Account>();
        List<Account> tier3 = new List<Account>();
        
        Tier1.add(new Account(Name = 'TestAccount- Ultimate Parent', Type = 'Prospect', Website = 'UltimateParent.com', Churned_Customer_Date__c = system.today().addDays(-1)));
        insert Tier1;
        
        Tier2.add(new Account(Name = 'TestAccount - ParentOne', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier2;
        
        tier3.add(new Account(Name = 'TestAccount - Child One', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier2.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com', Churned_Customer_Date__c = system.today()));
        insert tier3;
        
        Contact testContact = new Contact();
        testContact.LastName = 'testLastName';
        testContact.Email = 'testingtest1234@test.com';
        testContact.AccountId = tier3.get(0).Id;
        insert testContact;
        
        Case testCase = new Case();
        testCase.AccountId = Tier2.get(0).Id;
        testCase.ContactId = testContact.Id;
        testCase.Churn_Type__c = 'Billing Correction';
        testCase.Status = 'New';
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Churn').getRecordTypeId();
        insert testCase;
        
        test.startTest();
        testCase.Status = 'closed_Saved';
        update testCase;
        test.stopTest();
        
        Account testChildsAccount = [SELECT Id, Name, Churned_Customer_Date__c FROM Account WHERE Id IN: Tier2];
        system.assertEquals(tier1.get(0).Churned_Customer_Date__c, testChildsAccount.Churned_Customer_Date__c);
        
    }
    
    @isTest
    public static void testCaseUpdateCustomerDateFromOldest() { 
        
        List<Account> tier1 = new List<Account>();
        List<Account> tier2 = new List<Account>();
        List<Account> tier3 = new List<Account>();
        
        Tier1.add(new Account(Name = 'TestAccount- Ultimate Parent', Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier1;
        
        Tier2.add(new Account(Name = 'TestAccount - ParentOne', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com', Churned_Customer_Date__c = Date.newInstance(2023, 04, 01)));
        insert Tier2;
        
        tier3.add(new Account(Name = 'TestAccount - Child One', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier2.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com', Churned_Customer_Date__c = system.today()));
        tier3.add(new Account(Name = 'TestAccount - Child Two', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier2.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        insert tier3;
        
        Contact testContact = new Contact();
        testContact.LastName = 'testLastName';
        testContact.Email = 'testingtest1234@test.com';
        testContact.AccountId = tier3.get(0).Id;
        insert testContact;
        
        Case testCase = new Case();
        testCase.AccountId = tier3.get(1).Id;
        testCase.ContactId = testContact.Id;
        testCase.Churn_Type__c = 'Billing Correction';
        testCase.Status = 'New';
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Churn').getRecordTypeId();
        insert testCase;
        
        test.startTest();
        testCase.Status = 'closed_Saved';
        update testCase;
        test.stopTest();
        
        Account testChildsAccount = [SELECT Id, Name, Churned_Customer_Date__c FROM Account WHERE Id IN: Tier1];
        system.assertEquals(Date.newInstance(2023, 04, 01), testChildsAccount.Churned_Customer_Date__c);
        
    }
    
}