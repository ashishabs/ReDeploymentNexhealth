/**********************************************************
Class: CustomerLifecycleQueueableTest
LastModifiedBy: Cloud Connex 03/21/2023 
Description: This is Test class for the CustomerLifecycleQueueable     
***********************************************************/
@isTest
public class CustomerLifecycleQueueableTest {
    
    @isTest
    public static void testOppUpdateCustomerDateFromTier3(){
        List<Account> tier1 = new List<Account>();
        List<Account> tier2 = new List<Account>();
        List<Account> tier3 = new List<Account>();
        
        Tier1.add(new Account(Name = 'Ultimate Parent Tree 1', Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier1;
        
        Tier2.add(new Account(Name = 'Tier 2 Child 1 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        Tier2.add(new Account(Name = 'Tier 2 Child 2 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier2;
        
        tier3.add(new Account(Name = 'Tier 3 Child 3 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier2.get(1).Id, Type = 'Prospect', Website = 'UltimateParent.com', Became_a_Customer_Date__c = system.today()));
        insert tier3;
        
        Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = tier3.get(0).Id;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Pending';
        testOpp.CloseDate = system.today();
        testOpp.Close_Date_Timestamp__c = system.today();
        testOpp.Pricebook2Id = test.getStandardPricebookId();
        testOpp.RecordTypeId = theDevRecordTypeId;
        
        test.startTest();
        insert testOpp;
        test.stopTest();
        
        List<Account> testChildsAccounts = [SELECT Id, Name, Became_a_Customer_Date__c FROM Account WHERE Name like '%Tier 2' OR Name like '%Tier 3'];
        for(Account theAcnt : testChildsAccounts){
            system.assertEquals(system.today(), theAcnt.Became_a_Customer_Date__c);
        }
        
    }
    
    @isTest
    public static void testOppUpdateCustomerDateFromTier2(){
        List<Account> tier1 = new List<Account>();
        List<Account> tier2 = new List<Account>();
        List<Account> tier3 = new List<Account>();
        
        Tier1.add(new Account(Name = 'Ultimate Parent Tree 1', Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier1;
        
        Tier2.add(new Account(Name = 'Tier 2 Child 1 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        Tier2.add(new Account(Name = 'Tier 2 Child 2 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier2;
        
        tier3.add(new Account(Name = 'Tier 3 Child 3 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier2.get(1).Id, Type = 'Prospect', Website = 'UltimateParent.com', Became_a_Customer_Date__c = system.today()));
        insert tier3;
        
        Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = tier2.get(0).Id;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Pending';
        testOpp.CloseDate = system.today();
        testOpp.Close_Date_Timestamp__c = system.today();
        testOpp.Pricebook2Id = test.getStandardPricebookId();
        testOpp.RecordTypeId = theDevRecordTypeId;
        
        test.startTest();
        insert testOpp;
        test.stopTest();
        
        List<Account> testChildsAccounts = [SELECT Id, Name, Became_a_Customer_Date__c FROM Account WHERE Name like '%Tier 2' OR Name like '%Tier 3'];
        for(Account theAcnt : testChildsAccounts){
            system.assertEquals(system.today(), theAcnt.Became_a_Customer_Date__c);
        }
        
    }
    
    @isTest
    public static void testOppUpdateCustomerDateFromTier1(){
        List<Account> tier1 = new List<Account>();
        List<Account> tier2 = new List<Account>();
        List<Account> tier3 = new List<Account>();
        
        Tier1.add(new Account(Name = 'Ultimate Parent Tree 1', Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier1;
        
        Tier2.add(new Account(Name = 'Tier 2 Child 1 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        Tier2.add(new Account(Name = 'Tier 2 Child 2 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier2;
        
        tier3.add(new Account(Name = 'Tier 3 Child 3 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier2.get(1).Id, Type = 'Prospect', Website = 'UltimateParent.com', Became_a_Customer_Date__c = system.today()));
        insert tier3;
        
        Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = Tier1.get(0).Id;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Pending';
        testOpp.CloseDate = system.today();
        testOpp.Close_Date_Timestamp__c = system.today();
        testOpp.Pricebook2Id = test.getStandardPricebookId();
        testOpp.RecordTypeId = theDevRecordTypeId;
        
        test.startTest();
        insert testOpp;
        test.stopTest();
        
        List<Account> testChildsAccounts = [SELECT Id, Name, Became_a_Customer_Date__c FROM Account WHERE Name like '%Tier 2' OR Name like '%Tier 3'];
        for(Account theAcnt : testChildsAccounts){
            system.assertEquals(system.today(), theAcnt.Became_a_Customer_Date__c);
        }
        
    }
    
    @isTest
    public static void testCaseUpdateCustomerDateFromTier1() { 
        
        List<Account> tier1 = new List<Account>();
        List<Account> tier2 = new List<Account>();
        List<Account> tier3 = new List<Account>();
        
        Tier1.add(new Account(Name = 'Ultimate Parent Tree 1', Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier1;
        
        Tier2.add(new Account(Name = 'Tier 2 Child 1 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        Tier2.add(new Account(Name = 'Tier 2 Child 2 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier2;
        
        tier3.add(new Account(Name = 'Tier 3 Child 3 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier2.get(1).Id, Type = 'Prospect', Website = 'UltimateParent.com', Churned_Customer_Date__c = system.today()));
        insert tier3;
        
        Contact testContact = new Contact();
        testContact.LastName = 'testLastName';
        testContact.Email = 'testingtest@test.com';
        testContact.AccountId = tier3.get(0).Id;
        insert testContact;
        
        Case testCase = new Case();
        testCase.AccountId = Tier1.get(0).Id;
        testCase.ContactId = testContact.Id;
        testCase.Churn_Type__c = 'Billing Correction';
        
        test.startTest();
        insert testCase;
        test.stopTest();
        
        List<Account> testChildsAccounts = [SELECT Id, Name, Churned_Customer_Date__c FROM Account WHERE Name like '%Tier 2' OR Name like '%Tier 3'];
        for(Account theAcnt : testChildsAccounts){
            system.assertEquals(system.today(), theAcnt.Churned_Customer_Date__c);
        }
        
    }
    
    @isTest
    public static void testCaseUpdateCustomerDateFromTier2() { 
        
        List<Account> tier1 = new List<Account>();
        List<Account> tier2 = new List<Account>();
        List<Account> tier3 = new List<Account>();
        
        Tier1.add(new Account(Name = 'Ultimate Parent Tree 1', Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier1;
        
        Tier2.add(new Account(Name = 'Tier 2 Child 1 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        Tier2.add(new Account(Name = 'Tier 2 Child 2 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier2;
        
        tier3.add(new Account(Name = 'Tier 3 Child 3 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier2.get(1).Id, Type = 'Prospect', Website = 'UltimateParent.com', Churned_Customer_Date__c = system.today()));
        insert tier3;
        
        Contact testContact = new Contact();
        testContact.LastName = 'testLastName';
        testContact.Email = 'testingtest@test.com';
        testContact.AccountId = tier3.get(0).Id;
        insert testContact;
        
        Case testCase = new Case();
        testCase.AccountId = Tier2.get(1).Id;
        testCase.ContactId = testContact.Id;
        testCase.Churn_Type__c = 'Billing Correction';
        
        test.startTest();
        insert testCase;
        test.stopTest();
        
        List<Account> testChildsAccounts = [SELECT Id, Name, Churned_Customer_Date__c FROM Account WHERE Name like '%Tier 2' OR Name like '%Tier 3'];
        for(Account theAcnt : testChildsAccounts){
            system.assertEquals(system.today(), theAcnt.Churned_Customer_Date__c);
        }
        
    }
    
    @isTest
    public static void testCaseUpdateCustomerDateFromTier3() { 
        
        List<Account> tier1 = new List<Account>();
        List<Account> tier2 = new List<Account>();
        List<Account> tier3 = new List<Account>();
        
        Tier1.add(new Account(Name = 'Ultimate Parent Tree 1', Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier1;
        
        Tier2.add(new Account(Name = 'Tier 2 Child 1 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        Tier2.add(new Account(Name = 'Tier 2 Child 2 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier2;
        
        tier3.add(new Account(Name = 'Tier 3 Child 3 Tree 1', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier2.get(1).Id, Type = 'Prospect', Website = 'UltimateParent.com', Churned_Customer_Date__c = system.today()));
        insert tier3;
        
        Contact testContact = new Contact();
        testContact.LastName = 'testLastName';
        testContact.Email = 'testingtest@test.com';
        testContact.AccountId = tier3.get(0).Id;
        insert testContact;
        
        Case testCase = new Case();
        testCase.AccountId = Tier3.get(0).Id;
        testCase.ContactId = testContact.Id;
        testCase.Churn_Type__c = 'Billing Correction';
        
        test.startTest();
        insert testCase;
        test.stopTest();
        
        List<Account> testChildsAccounts = [SELECT Id, Name, Churned_Customer_Date__c FROM Account WHERE Name like '%Tier 2' OR Name like '%Tier 3'];
        for(Account theAcnt : testChildsAccounts){
            system.assertEquals(system.today(), theAcnt.Churned_Customer_Date__c);
        }
        
    }
}