/**********************************************************
Test Class: OpportunityTriggerhandlerTest
LastModifiedBy: Cloud Connex 07/25/2023
Class: OpportunityTriggerhandler
***********************************************************/
@istest
public class OpportunityTriggerhandlerTest {
    
    @testSetup
    public static void test_Setup() {
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User();
        testUser.Alias = 'tese';
        testUser.firstName = 'test1';
        testUser.lastName = 'test2';
        testUser.profileId = testProfile.id;
        testUser.username = 'testingDemoForEmailTemplate@Nexhealthtest.com';
        testUser.email = 'test@testing.com';
        testUser.TimeZoneSidKey = 'America/New_York';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LanguageLocaleKey = 'en_US';
        
        system.runAs(testUser){     
            List<EmailTemplate> testEmailTemplateList = new List<EmailTemplate>();
            
            EmailTemplate testTemplateforSmileDirect = new EmailTemplate();
            testTemplateforSmileDirect.Body = 'Body for SmileDirectClubTemplate';
            testTemplateforSmileDirect.DeveloperName = 'SmileDirectClubTemplate';
            testTemplateforSmileDirect.Subject = 'Subject for SmileDirectClubTemplate';
            testTemplateforSmileDirect.FolderId = UserInfo.getUserId();
            testTemplateforSmileDirect.Name = 'SmileDirectClubTemplate';
            testEmailTemplateList.add(testTemplateforSmileDirect);
            
            EmailTemplate testTemplateforTrueLark = new EmailTemplate();
            testTemplateforTrueLark.Body = 'Body for TrueLarkTemplate';
            testTemplateforTrueLark.DeveloperName = 'TrueLarkTemplate';
            testTemplateforTrueLark.Subject = 'Subject for TrueLarkTemplate';
            testTemplateforTrueLark.FolderId = UserInfo.getUserId();
            testTemplateforTrueLark.Name = 'TrueLarkTemplate';
            testEmailTemplateList.add(testTemplateforTrueLark);
            
            EmailTemplate testTemplateanythingElseTemplate = new EmailTemplate();
            testTemplateanythingElseTemplate.Body = 'Body for anythingElseTemplate';
            testTemplateanythingElseTemplate.DeveloperName = 'anythingElseTemplate';
            testTemplateanythingElseTemplate.Subject = 'Subject for anythingElseTemplate';
            testTemplateanythingElseTemplate.FolderId = UserInfo.getUserId();
            testTemplateanythingElseTemplate.Name = 'anythingElseTemplate';
            testEmailTemplateList.add(testTemplateanythingElseTemplate);
            
            EmailTemplate testTemplateforIbook = new EmailTemplate();
            testTemplateforIbook.Body = 'Body for iBookTemplate';
            testTemplateforIbook.DeveloperName = 'iBookTemplate';
            testTemplateforIbook.Subject = 'Subject for iBookTemplate';
            testTemplateforIbook.FolderId = UserInfo.getUserId();
            testTemplateforIbook.Name = 'iBookTemplate';
            testEmailTemplateList.add(testTemplateforIbook);
            
        }
        Campaign_Influence_Config__c testConfig = new Campaign_Influence_Config__c();
        testConfig.Date_range_before_Opportunity__c = 120;
        testConfig.Opportunity_Date_Field__c = 'CloseDate';
        insert testConfig;
        
        List<Product2> testProdList = new List<Product2>();
        Product2 testProd = new Product2();
        testProd.Name = 'testProd';
        testProd.ProductCode = 'PBCODE';
        testProd.isActive = true;
        testProdList.add(testProd);
        
        Product2 testProd1 = new Product2();
        testProd1.Name = 'testProd2';
        testProd1.ProductCode = 'PBCODES';
        testProd1.isActive = true;
        testProdList.add(testProd1);
        insert testProdList;
        
        List<PriceBookEntry> testPBEList = new List<PriceBookEntry>();
        PriceBookEntry testPBE = new PriceBookEntry();
        testPBE.Pricebook2Id = test.getStandardPricebookId();
        testPBE.Product2Id = testProd.Id;
        testPBE.UnitPrice = 300;
        testPBE.IsActive = true;
        testPBEList.add(testPBE);
        PriceBookEntry testPBE1 = new PriceBookEntry();
        testPBE1.Pricebook2Id = test.getStandardPricebookId();
        testPBE1.Product2Id = testProd1.Id;
        testPBE1.UnitPrice = 150;
        testPBE1.IsActive = true;
        testPBEList.add(testPBE1);
        insert testPBEList;
        
        Account testacnt = new Account();
        testacnt.Name = 'testAcnt';
        insert testacnt;
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = testacnt.Id;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Pending';
        testOpp.CloseDate = system.today();
        testOpp.Pricebook2Id = test.getStandardPricebookId();
        insert testOpp;
        
        List<OpportunityLineItem> testOLIList = new List<OpportunityLineItem>();
        OpportunityLineItem testItems = new OpportunityLineItem();
        testItems.OpportunityId = testOpp.Id;
        testItems.PricebookEntryId = testPBE.Id;
        testItems.UnitPrice = 100;
        testItems.Quantity = 5;
        testOLIList.add(testItems);
        
        OpportunityLineItem testItem1 = new OpportunityLineItem();
        testItem1.OpportunityId = testOpp.Id;
        testItem1.PricebookEntryId = testPBE1.Id;
        testItem1.UnitPrice = 200;
        testItem1.Quantity = 5;
        testOLIList.add(testItem1);    
        
        insert testOLIList;
    }
    
    @isTest
    public static void restrictOppWithContractSenttest(){
        
        Opportunity testOpp = [SELECT Id, StageName FROM Opportunity];
        test.startTest();
        testOpp.StageName = 'Contract Sent';
        try{
            update testOpp;
        }catch(Exception e){
            System.assert(e.getMessage().Contains('Opportunities cannot be moved into Contract Sent or Closed Won'));
        }
        test.stopTest();
    }
    
    @isTest
    public static void restrictOppWithEmptyDiscountReasontest(){
        String theError = '';
        Opportunity testOpp = [SELECT Id, StageName FROM Opportunity];
        testOpp.StageName = 'Contract Sent';
        testOpp.Discount_Reason__c = 'Case Study';
        testOpp.number_of_locations__c = 10;
        test.startTest();
        try{
            update testOpp;
        }catch(Exception e){
            theError = e.getMessage();
        }
        test.stopTest();
        system.assertEquals(theError, '');
        
    }
    
    
    @isTest
    public static void UpdateAccountDeveloperStatusTest() {
        
        Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Developer').getRecordTypeId();
        Opportunity testOpp = [SELECT Id, StageName FROM Opportunity];
        
        Contact testContact = new Contact();
        testContact.LastName = 'testName';
        insert testContact;
        
        OpportunityContactRole testOCR = new OpportunityContactRole();
        testOCR.ContactId = testContact.Id;
        testOCR.OpportunityId = testOpp.Id;
        testOCR.IsPrimary = TRUE;
        testOCR.Role = 'Implementation Contact';
        test.startTest();
        insert testOCR;
        
        //test.startTest();
        testOpp.StageName = 'Closed Won';
        testOpp.RecordTypeId = theDevRecordTypeId;
        testOpp.Discount_Reason__c = 'Case Study';
        testOpp.win_reason__c = 'Product Fit';
        testOpp.primary_implementation_contact__c = testContact.Id;
        testOpp.Developer_Payment_Type__c = 'Paying per Location';
        testOpp.number_of_locations__c = 5;
        update testOpp;
        test.stopTest();
        
        Account testAcntForAssertion = [SELECT Id, Developer_Status__c FROM Account];
        Contact testContForAssertion = [SELECT Id, Developer_Status__c FROm Contact];
        //Assertion
        //system.assertEquals('Active', testAcntForAssertion.Developer_Status__c);
        //system.assertEquals('Active', testContForAssertion.Developer_Status__c);
    }
    
    
    @isTest
    public static void UpdateAccountRecordTypeCustomerTest() {
        
        Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        
        Contact testContact = new Contact();
        testContact.LastName = 'testName';
        insert testContact; 
        
        Opportunity testOpp = [SELECT Id, StageName FROM Opportunity];
        
        OpportunityContactRole testOCR = new OpportunityContactRole();
        testOCR.ContactId = testContact.Id;
        testOCR.OpportunityId = testOpp.Id;
        testOCR.IsPrimary = TRUE;
        testOCR.Role = 'Implementation Contact';
        test.startTest();
        insert testOCR;
        
        //test.startTest();
        testOpp.StageName = 'Closed Won';
        testOpp.RecordTypeId = theDevRecordTypeId;
        testOpp.Discount_Reason__c = 'Case Study';
        testOpp.win_reason__c = 'Product Fit';
        testOpp.primary_implementation_contact__c = testContact.Id;
        testOpp.Developer_Payment_Type__c = 'Paying per Location';
        testOpp.number_of_locations__c = 5;
        update testOpp;
        test.stopTest();
        
        Account testAcntForAssertion = [SELECT Id, RecordTypeId FROM Account];
        //Assertion
        system.assertEquals(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(), testAcntForAssertion.RecordTypeId);
    }
    
    @isTest
    public static void UpdateAccountRecordTypePartnerTest() {
        
        Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Referral Partnership').getRecordTypeId();
        
        Contact testContact = new Contact();
        testContact.LastName = 'testName';
        insert testContact; 
        
        Opportunity testOpp = [SELECT Id, StageName FROM Opportunity];
        
        OpportunityContactRole testOCR = new OpportunityContactRole();
        testOCR.ContactId = testContact.Id;
        testOCR.OpportunityId = testOpp.Id;
        testOCR.IsPrimary = TRUE;
        testOCR.Role = 'Implementation Contact';
        test.startTest();
        insert testOCR;
        
        //test.startTest();
        testOpp.StageName = 'Closed Won';
        testOpp.RecordTypeId = theDevRecordTypeId;
        testOpp.Discount_Reason__c = 'Case Study';
        testOpp.win_reason__c = 'Product Fit';
        testOpp.primary_implementation_contact__c = testContact.Id;
        testOpp.Developer_Payment_Type__c = 'Paying per Location';
        testOpp.number_of_locations__c = 5;
        update testOpp;
        test.stopTest();
        
        Account testAcntForAssertion = [SELECT Id, RecordTypeId FROM Account];
        //Assertion
        system.assertEquals(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId(), testAcntForAssertion.RecordTypeId);
    }
    
    
    @isTest
    public static void UpdateAccountRecordTypeProspectTest() {
        
        Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Referral Partnership').getRecordTypeId();
        
        Opportunity testOpp = [SELECT Id, StageName FROM Opportunity];
        
        test.startTest();
        testOpp.RecordTypeId = theDevRecordTypeId;
        update testOpp;
        test.stopTest();
        
        Account testAcntForAssertion = [SELECT Id, RecordTypeId FROM Account];
        //Assertion
        system.assertEquals(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(), testAcntForAssertion.RecordTypeId);
    }
    
    
    @isTest
    public static void updateOCRContactDateTest() {
        
        Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Developer').getRecordTypeId();
        Opportunity testOpp = [SELECT Id, StageName FROM Opportunity];
        
        Contact testContact = new Contact();
        testContact.LastName = 'testName';
        insert testContact;
        
        OpportunityContactRole testOCR = new OpportunityContactRole();
        testOCR.ContactId = testContact.Id;
        testOCR.OpportunityId = testOpp.Id;
        testOCR.IsPrimary = TRUE;
        testOCR.Role = 'Implementation Contact';
        test.startTest();
        insert testOCR;
        
        //test.startTest();
        testOpp.StageName = 'Closed Lost';
        testOpp.RecordTypeId = theDevRecordTypeId;
        testOpp.Discount_Reason__c = 'Case Study';
        testOpp.Loss_reason__c = 'Duplicate';
        testOpp.primary_implementation_contact__c = testContact.Id;
        testOpp.Developer_Payment_Type__c = 'Paying per Location';
        testOpp.number_of_locations__c = 5;
        update testOpp;
        test.stopTest();
        
        Contact testContForAssertion = [SELECT Id, Closed_Lost_Opportunity_date__c, Developer_Status__c FROM Contact];
        //Assertion
        System.AssertEquals(System.today(), testContForAssertion.Closed_Lost_Opportunity_date__c);
        
    }
    
    @isTest
    public static void updateOCRContactDatetoNullTest() {
        
        Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Developer').getRecordTypeId();
        Opportunity testOpp = [SELECT Id, StageName FROM Opportunity];
        
        Contact testContact = new Contact();
        testContact.LastName = 'testName';
        testContact.Closed_Lost_Opportunity_date__c = System.today();
        insert testContact;
        
        OpportunityContactRole testOCR = new OpportunityContactRole();
        testOCR.ContactId = testContact.Id;
        testOCR.OpportunityId = testOpp.Id;
        testOCR.IsPrimary = TRUE;
        testOCR.Role = 'Implementation Contact';
        test.startTest();
        insert testOCR;
        
        //test.startTest();
        testOpp.StageName = 'Closed Won';
        testOpp.RecordTypeId = theDevRecordTypeId;
        testOpp.Discount_Reason__c = 'Case Study';
        testOpp.win_reason__c = 'Product Fit';
        testOpp.primary_implementation_contact__c = testContact.Id;
        testOpp.Developer_Payment_Type__c = 'Paying per Location';
        testOpp.number_of_locations__c = 5;
        update testOpp;
        test.stopTest();
        
        Contact testContForAssertion = [SELECT Id, Closed_Lost_Opportunity_date__c, Developer_Status__c FROM Contact];
        //Assertion
        System.AssertEquals(null, testContForAssertion.Closed_Lost_Opportunity_date__c);
    }
    
    @isTest
    public static void updateOCRContactDateBulkTest() {
        
        Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Developer').getRecordTypeId();
        Opportunity testOpp = [SELECT Id, StageName,CloseDate FROM Opportunity];
        
        List<Contact> testContList = new List<Contact>();
        
        Contact testContact = new Contact();
        testContact.LastName = 'testName 1';
        testContList.add(testContact);
        
        Contact testContact2 = new Contact();
        testContact2.LastName = 'testName 2';
        testContList.add(testContact2);
        
        if(!testContList.isEmpty()) insert testContList;
        
        List<OpportunityContactRole> testOppContRoleList = New List<OpportunityContactRole>();  
        OpportunityContactRole testOCR = new OpportunityContactRole();
        testOCR.ContactId = testContact.Id;
        testOCR.OpportunityId = testOpp.Id;
        testOCR.IsPrimary = TRUE;
        testOCR.Role = 'Implementation Contact';
        testOppContRoleList.add(testOCR); 
        
        OpportunityContactRole testOCR2 = new OpportunityContactRole();
        testOCR2.ContactId = testContact2.Id;
        testOCR2.OpportunityId = testOpp.Id;
        testOCR2.IsPrimary = TRUE;
        testOCR2.Role = 'Billing Contact';
        testOppContRoleList.add(testOCR2); 
        test.startTest();
        insert testOppContRoleList;
        
        //test.startTest();
        testOpp.StageName = 'Closed Lost';
        testOpp.RecordTypeId = theDevRecordTypeId;
        testOpp.Discount_Reason__c = 'Case Study';
        testOpp.Loss_reason__c = 'Duplicate';
        testOpp.primary_implementation_contact__c = testContact.Id;
        testOpp.Developer_Payment_Type__c = 'Paying per Location';
        testOpp.number_of_locations__c = 5;
        update testOpp;
        test.stopTest();
        
        List<Contact> testContForAssertion = [SELECT Id,Last_Opportunity_Record_Type__c,Last_Opportunity_Close_Date__c,Last_Opportunity_Contact_Role__c,Last_Opportunity_Stage__c, Closed_Lost_Opportunity_date__c, Developer_Status__c From Contact WHERE Id =: testContact2.Id];
        //Assertion
        for(Contact  testContForAssert: testContForAssertion){
            System.AssertEquals(System.today(), testContForAssert.Closed_Lost_Opportunity_date__c);
            System.AssertEquals(testOpp.CloseDate, testContForAssert.Last_Opportunity_Close_Date__c);
            System.AssertEquals('Billing Contact', testContForAssert.Last_Opportunity_Contact_Role__c);
            System.AssertEquals(testOpp.StageName, testContForAssert.Last_Opportunity_Stage__c);
        }   
    }
    
    @isTest
    public static void updateOCRContactDatetoNullBulkTest() {
        
        Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Developer').getRecordTypeId();
        Opportunity testOpp = [SELECT Id, StageName,CloseDate FROM Opportunity];
        List<Contact> testContList = new List<Contact>();
        
        Contact testContact = new Contact();
        testContact.LastName = 'testName 1';
        testContact.Closed_Lost_Opportunity_date__c = System.today();
        testContList.add(testContact);
        
        Contact testContact2 = new Contact();
        testContact2.LastName = 'testName 2';
        testContact.Closed_Lost_Opportunity_date__c = System.today();
        testContList.add(testContact2);
        
        if(!testContList.isEmpty()) insert testContList;
        
        List<OpportunityContactRole> testOppContRoleList = New List<OpportunityContactRole>();  
        OpportunityContactRole testOCR = new OpportunityContactRole();
        testOCR.ContactId = testContact.Id;
        testOCR.OpportunityId = testOpp.Id;
        testOCR.IsPrimary = TRUE;
        testOCR.Role = 'Implementation Contact';
        testOppContRoleList.add(testOCR); 
        
        OpportunityContactRole testOCR2 = new OpportunityContactRole();
        testOCR2.ContactId = testContact2.Id;
        testOCR2.OpportunityId = testOpp.Id;
        testOCR2.IsPrimary = TRUE;
        testOCR2.Role = 'Billing Contact';
        testOppContRoleList.add(testOCR2); 
        test.startTest();
        insert testOppContRoleList;
        
        //test.startTest();
        testOpp.StageName = 'Closed Won';
        testOpp.RecordTypeId = theDevRecordTypeId;
        testOpp.Discount_Reason__c = 'Case Study';
        testOpp.win_reason__c = 'Product Fit';
        testOpp.primary_implementation_contact__c = testContact.Id;
        testOpp.Developer_Payment_Type__c = 'Paying per Location';
        testOpp.number_of_locations__c = 5;
        update testOpp;
        test.stopTest();
        
        List<Contact> testContForAssertion = [SELECT Id,Last_Opportunity_Record_Type__c,Last_Opportunity_Close_Date__c,Last_Opportunity_Contact_Role__c,Last_Opportunity_Stage__c, Closed_Lost_Opportunity_date__c, Developer_Status__c From Contact WHERE Id =: testContact2.Id];
        //Assertion
        for(Contact  testContForAssert: testContForAssertion){
            System.AssertEquals(null, testContForAssert.Closed_Lost_Opportunity_date__c);
        }   
        
    }
    
    @isTest
    public static void updateOCRContactDateBulkTest1() {
        
        Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Developer').getRecordTypeId();
        Opportunity testOpp = [SELECT Id, StageName,CloseDate FROM Opportunity];
        List<Contact> testContList = new List<Contact>();
        
        Contact testContact = new Contact();
        testContact.LastName = 'testName 1';
        testContList.add(testContact);
        
        Contact testContact2 = new Contact();
        testContact2.LastName = 'testName 2';
        testContList.add(testContact2);
        
        if(!testContList.isEmpty()) insert testContList;
        
        List<OpportunityContactRole> testOppContRoleList = New List<OpportunityContactRole>();  
        OpportunityContactRole testOCR = new OpportunityContactRole();
        testOCR.ContactId = testContact.Id;
        testOCR.OpportunityId = testOpp.Id;
        testOCR.IsPrimary = TRUE;
        testOCR.Role = 'Decision Maker';
        testOppContRoleList.add(testOCR); 
        
        OpportunityContactRole testOCR2 = new OpportunityContactRole();
        testOCR2.ContactId = testContact2.Id;
        testOCR2.OpportunityId = testOpp.Id;
        testOCR2.Role = 'Billing Contact';
        testOppContRoleList.add(testOCR2); 
        test.startTest();
        insert testOppContRoleList;
        
        testOpp.StageName = 'Closed Lost';
        testOpp.RecordTypeId = theDevRecordTypeId;
        testOpp.Discount_Reason__c = 'Case Study';
        testOpp.Loss_reason__c = 'Duplicate';
        testOpp.primary_implementation_contact__c = testContact.Id;
        testOpp.Developer_Payment_Type__c = 'Paying per Location';
        testOpp.number_of_locations__c = 5;
        
        //test.startTest();
        update testOpp;
        test.stopTest();    
        
        List<Contact> testContForAssertion = [SELECT Id, Last_Opportunity_Created_Date__c, Last_Opportunity_Contact_Role__c, Last_Opportunity_Closed_Won_Reason__c, Last_Opportunity_Closed_Lost_Reason__c, Closed_Lost_Opportunity_date__c, Last_Opportunity_Close_Date__c, Last_Opportunity_Stage__c, Last_Opportunity_Record_Type__c FROM Contact WHERE Id =: testContact.Id];
        for(Contact testCon : testContForAssertion) {
            System.AssertEquals(System.today(), testCon.Closed_Lost_Opportunity_date__c);
            System.AssertEquals(testOpp.CloseDate, testCon.Last_Opportunity_Close_Date__c);
            System.AssertEquals('Decision Maker', testCon.Last_Opportunity_Contact_Role__c);
            System.AssertNotEquals(null, testCon.Last_Opportunity_Stage__c);
            System.AssertNotEquals(null, testCon.Last_Opportunity_Record_Type__c);
            System.AssertNotEquals(null, testCon.Last_Opportunity_Closed_Lost_Reason__c);
            System.AssertEquals(null, testCon.Last_Opportunity_Closed_Won_Reason__c);
            System.AssertNotEquals(null, testCon.Last_Opportunity_Contact_Role__c);
            System.AssertNotEquals(null, testCon.Last_Opportunity_Created_Date__c);
            System.assertNotEquals(null, testCon.Last_Opportunity_Stage__c);   
        }
        
    }
    
    @isTest    
    public static void OppInstallCompleteEmailNotificationTestForIBook() {
        
        Account testAcnt = new Account();
        testAcnt.Name = 'iBook';
        insert testAcnt;
        
        List<Contact> testContList = new List<Contact>();
        Contact testCont = new Contact();
        testCont.LastName = 'testContLastName';
        testCont.Email = 'Test@test.com';
        testCont.AccountId = testAcnt.Id;
        testCont.Send_API_Install_Updates__c = true;
        testContList.add(testCont);
        
        Contact testCont1 = new Contact();
        testCont1.LastName = 'testContLastName2';
        testCont1.AccountId = testAcnt.Id;
        testCont1.Email = 'Test@test.com';
        testCont1.Send_API_Install_Updates__c = true;
        testContList.add(testCont1);
        
        insert testContList;
        
        Opportunity testOpp = new Opportunity();
        testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API Access').getRecordTypeId();
        testOpp.referral_source__c = testAcnt.Id;
        testOpp.Name = 'testOpp1';
        testOpp.StageName = 'Install Complete';
        testOpp.CloseDate = system.today();
        
        Test.startTest();
        insert testOpp;
        Test.stopTest();
        
        List<Task> testTaskQuery = [SELECT Id FROM Task WHERE WhatId =: testOpp.Id Limit 1];
        System.assertEquals(1, testTaskQuery.size());
    }
    
    @isTest    
    public static void OppInstallCompleteEmailNotificationTestForSmileDirectClub() {
        
        Account testAcnt = new Account();
        testAcnt.Name = 'Smile Direct Club';
        insert testAcnt;
        
        List<Contact> testContList = new List<Contact>();
        Contact testCont = new Contact();
        testCont.LastName = 'testContLastName';
        testCont.Email = 'Test@test.com';
        testCont.AccountId = testAcnt.Id;
        testCont.Send_API_Install_Updates__c = true;
        testContList.add(testCont);
        
        Contact testCont1 = new Contact();
        testCont1.LastName = 'testContLastName2';
        testCont1.AccountId = testAcnt.Id;
        testCont1.Email = 'Test@test.com';
        testCont1.Send_API_Install_Updates__c = true;
        testContList.add(testCont1);
        
        insert testContList;
        
        Opportunity testOpp = new Opportunity();
        testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API Access').getRecordTypeId();
        testOpp.referral_source__c = testAcnt.Id;
        testOpp.Name = 'testOpp1';
        testOpp.StageName = 'Install Complete';
        testOpp.CloseDate = system.today();
        
        Test.startTest();
        insert testOpp;
        Test.stopTest();
        
        List<Task> testTaskQuery = [SELECT Id FROM Task WHERE WhatId =: testOpp.Id Limit 1];
        System.assertEquals(1, testTaskQuery.size());
    }
    
    @isTest    
    public static void OppInstallCompleteEmailNotificationTestForTrueLark() {
        
        Account testAcnt = new Account();
        testAcnt.Name = 'TrueLark';
        insert testAcnt;
        
        List<Contact> testContList = new List<Contact>();
        Contact testCont = new Contact();
        testCont.LastName = 'testContLastName';
        testCont.Email = 'Test@test.com';
        testCont.AccountId = testAcnt.Id;
        testCont.Send_API_Install_Updates__c = true;
        testContList.add(testCont);
        
        Contact testCont1 = new Contact();
        testCont1.LastName = 'testContLastName2';
        testCont1.AccountId = testAcnt.Id;
        testCont1.Email = 'Test@test.com';
        testCont1.Send_API_Install_Updates__c = true;
        testContList.add(testCont1);
        
        insert testContList;
        
        Opportunity testOpp = new Opportunity();
        testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API Access').getRecordTypeId();
        testOpp.referral_source__c = testAcnt.Id;
        testOpp.Name = 'testOpp1';
        testOpp.StageName = 'Install Complete';
        testOpp.CloseDate = system.today();
        
        Test.startTest();
        insert testOpp;
        Test.stopTest();
        
        List<Task> testTaskQuery = [SELECT Id FROM Task WHERE WhatId =: testOpp.Id Limit 1];
        System.assertEquals(1, testTaskQuery.size());
    }
    
    @isTest    
    public static void OppInstallCompleteEmailTestForTrue() {
        
        Account testAcnt = new Account();
        testAcnt.Name = 'TrueLark';
        insert testAcnt;
        
        List<Contact> testContList = new List<Contact>();
        Contact testCont = new Contact();
        testCont.LastName = 'testContLastName';
        testCont.Email = 'Test@test.com';
        testCont.AccountId = testAcnt.Id;
        testCont.Send_API_Install_Updates__c = true;
        testContList.add(testCont);
        
        Contact testCont1 = new Contact();
        testCont1.LastName = 'testContLastName2';
        testCont1.AccountId = testAcnt.Id;
        testCont1.Email = 'Test@test.com';
        testCont1.Send_API_Install_Updates__c = true;
        testContList.add(testCont1);
        
        insert testContList;
        
        Opportunity testOpp = new Opportunity();
        testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API Access').getRecordTypeId();
        testOpp.referral_source__c = testAcnt.Id;
        testOpp.Name = 'testOpp1';
        testOpp.StageName = 'Install Complete';
        testopp.Do_not_send_API_Install_Completed_Email__c = true;
        testOpp.CloseDate = system.today();
        
        Test.startTest();
        insert testOpp;
        Test.stopTest();
        
        List<Task> testTaskQuery = [SELECT Id FROM Task WHERE WhatId =: testOpp.Id Limit 1];
        System.assertEquals(0, testTaskQuery.size());
    }
    
    @isTest    
    public static void OppInstallEmailForReferralContact() {
        
        Account testAcnt = new Account();
        testAcnt.Name = 'TrueLark';
        insert testAcnt;
        
        List<Contact> testContList = new List<Contact>();
        Contact testCont = new Contact();
        testCont.LastName = 'testContLastName';
        testCont.AccountId = testAcnt.Id;
        testCont.Email = 'Test@test.com';
        testContList.add(testCont);
        
        Contact testCont1 = new Contact();
        testCont1.LastName = 'testContLastName2';
        testCont1.Email = 'Test@test.com';
        testCont1.Send_API_Install_Updates__c = true;
        testContList.add(testCont1);
        
        insert testContList;
        
        Opportunity testOpp = new Opportunity();
        testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API Access').getRecordTypeId();
        testOpp.referral_source__c = testAcnt.Id;
        testOpp.Referral_Contact__c = testContList[1].Id;
        testOpp.Name = 'testOpp1';
        testOpp.StageName = 'Install Complete';
        testOpp.CloseDate = system.today();
        
        Test.startTest();
        insert testOpp;
        Test.stopTest();
        
        List<Task> testTaskQuery = [SELECT Id FROM Task WHERE WhatId =: testOpp.Id Limit 1];
        System.assertEquals(1, testTaskQuery.size());
    }
    
    @isTest    
    public static void OppInstallEmailForReferralContactWithoutSendAPIInstallUpdatesTrue() {
        
        Account testAcnt = new Account();
        testAcnt.Name = 'TrueLark';
        insert testAcnt;
        
        List<Contact> testContList = new List<Contact>();
        Contact testCont = new Contact();
        testCont.LastName = 'testContLastName';
        testCont.AccountId = testAcnt.Id;
        testCont.Email = 'Test@test.com';
        testContList.add(testCont);
        
        Contact testCont1 = new Contact();
        testCont1.LastName = 'testContLastName2';
        testCont1.Email = 'Test@test.com';
        testContList.add(testCont1);
        
        insert testContList;
        
        Opportunity testOpp = new Opportunity();
        testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('API Access').getRecordTypeId();
        testOpp.referral_source__c = testAcnt.Id;
        testOpp.Referral_Contact__c = testContList[1].Id;
        testOpp.Name = 'testOpp1';
        testOpp.StageName = 'Install Complete';
        testOpp.CloseDate = system.today();
        
        Test.startTest();
        insert testOpp;
        Test.stopTest();
        
        List<Task> testTaskQuery = [SELECT Id FROM Task WHERE WhatId =: testOpp.Id Limit 1];
        System.assertEquals(1, testTaskQuery.size());
    }
    
    @isTest
    public static void testOppUpdateCustomerDateFromUltimateparentDate(){
        List<Account> tier1 = new List<Account>();
        List<Account> tier2 = new List<Account>();
        List<Account> tier3 = new List<Account>();
        List<Account> tier4 = new List<Account>();
        
        Tier1.add(new Account(Name = 'TestAccount- Ultimate Parent', Type = 'Prospect', Website = 'UltimateParent.com', Became_a_Customer_Date__c = Date.newInstance(2023, 04, 01)));
        insert Tier1;
        
        Tier2.add(new Account(Name = 'TestAccount - ParentOne', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier2;
        
        tier3.add(new Account(Name = 'TestAccount - Child One', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier2.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com', Became_a_Customer_Date__c = system.today()));
        tier3.add(new Account(Name = 'TestAccount - Child Two', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier2.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com', Became_a_Customer_Date__c = system.today()));
        insert tier3;
        
        tier4.add(new Account(Name = 'TestAccount - Grand Child One', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier3.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com', Became_a_Customer_Date__c = Date.newInstance(2023, 04, 01)));
        insert tier4;
        
        Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = tier4.get(0).Id;
        testOpp.Name = 'testOpp';
        testOpp.CloseDate = system.today();
        testOpp.StageName = 'Requalify';
        testOpp.RecordTypeId = theDevRecordTypeId;
        testOpp.Discount_Reason__c = 'Case Study';
        testOpp.Developer_Payment_Type__c = 'Paying per Location';
        testOpp.number_of_locations__c = 5;
        insert testOpp;
        
        test.startTest();
        testOpp.StageName = 'Closed Won';
        testOpp.win_reason__c = 'Product Fit';
        Update testOpp;
        test.stopTest();
        
        Account testChildsAccount = [SELECT Id, Name, Became_a_Customer_Date__c FROM Account WHERE Id IN: Tier2];
        system.assertEquals(Date.newInstance(2023, 04, 01), testChildsAccount.Became_a_Customer_Date__c);
        
    }
    
    @isTest
    public static void testOppUpdateCustomerDateFromOldestDate(){
        List<Account> tier1 = new List<Account>();
        List<Account> tier2 = new List<Account>();
        List<Account> tier3 = new List<Account>();
        List<Account> tier4 = new List<Account>();
        
        Tier1.add(new Account(Name = 'TestAccount- Ultimate Parent', Type = 'Prospect', Website = 'UltimateParent.com'));
        insert Tier1;
        
        Tier2.add(new Account(Name = 'TestAccount - ParentOne', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier1.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com', Became_a_Customer_Date__c = Date.newInstance(2022, 04, 02)));
        insert Tier2;
        
        tier3.add(new Account(Name = 'TestAccount - Child One', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier2.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com', Became_a_Customer_Date__c = system.today()));
        tier3.add(new Account(Name = 'TestAccount - Child Two', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier2.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com', Became_a_Customer_Date__c = system.today().addDays(-1)));
        insert tier3;
        
        tier4.add(new Account(Name = 'TestAccount - Grand Child One', Ultimate_Parent__c = Tier1.get(0).Id, ParentId = Tier3.get(0).Id, Type = 'Prospect', Website = 'UltimateParent.com', Became_a_Customer_Date__c = Date.newInstance(2023, 04, 01)));
        insert tier4;
        
        Id theDevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = tier4.get(0).Id;
        testOpp.Name = 'testOpp';
        testOpp.CloseDate = system.today();
        testOpp.StageName = 'Requalify';
        testOpp.RecordTypeId = theDevRecordTypeId;
        testOpp.Discount_Reason__c = 'Case Study';
        testOpp.Developer_Payment_Type__c = 'Paying per Location';
        testOpp.number_of_locations__c = 5;
        insert testOpp;
        
        test.startTest();
        testOpp.StageName = 'Closed Won';
        testOpp.win_reason__c = 'Product Fit';
        Update testOpp;
        test.stopTest();
        
        Account testChildsAccount = [SELECT Id, Name, Became_a_Customer_Date__c FROM Account WHERE Id IN: Tier1];
        system.assertEquals(Date.newInstance(2022, 04, 02), testChildsAccount.Became_a_Customer_Date__c);
        
    }
   
    
}