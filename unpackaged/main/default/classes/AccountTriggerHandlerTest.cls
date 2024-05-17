/**********************************************************
Class: AccountTriggerHandlerTest
LastModifiedBy: Bopsy 04/20/2023
Description: This is Test class for the AccountTriggerHandler     
***********************************************************/
@istest
public class AccountTriggerHandlerTest {
    
    @testSetup
    public static void setup() {  
        
        List<Account> tier1 = new List<Account>();
        
        Tier1.add(new Account(Name = 'TestNoHierarchy - Ultimate Parent',
                              Type = 'Prospect',         
                              Website = 'TestNoHierarchyUltimateParent.com'
                             )
                 );
        
        Tier1.add(new Account(Name = 'TestSingleTierHierarchy - Ultimate Parent',
                              Type = 'Prospect',         
                              Website = 'TestSingleTierHierarchyUltimateParent.com'
                             )
                 );
        
        Tier1.add(new Account(Name = 'TestTwoTierHierarchyModifyingTier1 - Ultimate Parent',
                              Type = 'Prospect',         
                              Website = 'TestTwoTierHierarchyModifyingTier1UltimateParent.com'
                             )
                 );
        
        Tier1.add(new Account(Name = 'TestTwoTierHierarchyModifyingTier2 - Ultimate Parent',
                              Type = 'Prospect',         
                              Website = 'TestTwoTierHierarchyModifyingTier2UltimateParent.com'
                             )
                 );
        
        insert Tier1;
        
    }
    
    @istest
    public static void testNoHierachyLevel(){
        
        //Create Child Account
        Account testAcnt = new Account();
        testAcnt.Name = 'TestNoHierarchy - Child';
        testAcnt.Type = 'Prospect';
        
        test.startTest();
        insert testAcnt;
        test.stopTest();
        
        Account testAccount = [SELECT Id, ParentId, Ultimate_Parent__c,Type,Total_Child_Locations__c,Hierarchy_Level__c FROM Account WHERE Id =: testAcnt.id];
        System.assertEquals(null, testAccount.ParentId);
        System.assertEquals(null,testAccount.Ultimate_Parent__c);
         System.assertEquals(null,testAccount.Total_Child_Locations__c);
        System.assertEquals(null,testAccount.Hierarchy_Level__c);
        
    }
    
    @istest
    public static void testSingleTierHierachyLevel(){
        
        Account testAccount = [SELECT id, Name,Type,Total_Child_Locations__c,Hierarchy_Level__c FROM Account WHERE Name= 'TestSingleTierHierarchy - Ultimate Parent'];
        
        //Create Child Account
        Account testAcnt = new Account();
        testAcnt.Name = 'TestSingleHierarchy - Child';
        testAcnt.Type = 'Practice Location';
        testAcnt.ParentId = testAccount.Id;
        
        test.startTest();
        insert testAcnt;
        test.stopTest();
        
        testAccount = [SELECT id, Name,Type,Total_Child_Locations__c,Hierarchy_Level__c FROM Account WHERE Id =: testAccount.id];
        Account testAccountChild = [SELECT Id, ParentId, Ultimate_Parent__c,Type,Total_Child_Locations__c,Hierarchy_Level__c FROM Account WHERE Id =: testAcnt.id];
        System.assertEquals(testAccount.Id, testAccountChild.ParentId);
        System.assertEquals(testAccount.Id,testAccountChild.Ultimate_Parent__c);
    }
    
    @istest
    public static void testTestTwoTierHierarchyModifyingTeir1(){
        
        Account testUltimateParent = [SELECT id, Name,Type,Total_Child_Locations__c,Hierarchy_Level__c FROM Account WHERE Name= 'TestTwoTierHierarchyModifyingTier1 - Ultimate Parent'];
        
        //Create SubParent Account
        Account testSubParent = new Account();
        testSubParent.Name = 'TestTwoTierHierarchyModifyingTier1 - Sub-Parent';
        testSubParent.Type = 'Prospect';
        testSubParent.ParentId = testUltimateParent.Id;
        insert testSubParent;
        
        //Create Child Account
        Account testChildAccount = new Account();
        testChildAccount.Name = 'TestTwoTierHierarchyModifyingTier1 - ChildAccount';
        testChildAccount.Type = 'Practice Location';
        testChildAccount.ParentId = testSubParent.Id;
        
        test.startTest();
        insert testChildAccount;        
        test.stopTest();
        
        List<Account> testAccountHiearchyList = [SELECT Id, ParentId, Ultimate_Parent__c,Total_Child_Locations__c,Hierarchy_Level__c FROM Account WHERE Id =: testChildAccount.id OR Id =: testSubParent.Id];
        for(Account theAcnt : testAccountHiearchyList){
            System.assertEquals(testUltimateParent.Id,theAcnt.Ultimate_Parent__c);
        }
        
    }
    
    @istest
    public static void testTestTwoTierHierarchyModifyingTeir2(){
        
        Account testUltimateParent = [SELECT id, Name FROM Account WHERE Name= 'TestTwoTierHierarchyModifyingTier2 - Ultimate Parent'];
        
        //Create SubParent Account
        Account testSubParent = new Account();
        testSubParent.Name = 'TestTwoTierHierarchyModifyingTier1 - Sub-Parent';
        testSubParent.Type = 'Prospect';
        insert testSubParent;
        
        //Create Child Account
        Account testChildAccount = new Account();
        testChildAccount.Name = 'TestTwoTierHierarchyModifyingTier1 - ChildAccount';
        testChildAccount.Type = 'Prospect';
        testChildAccount.ParentId = testSubParent.Id;
        insert testChildAccount;   
        
        test.startTest();
        testSubParent.ParentId = testUltimateParent.Id;
        update testSubParent;
        test.stopTest();
        
        List<Account> testAccountHiearchyList = [SELECT Id, ParentId, Ultimate_Parent__c FROM Account WHERE Id =: testChildAccount.id OR Id =: testSubParent.Id];
        for(Account theAcnt : testAccountHiearchyList){
            System.assertEquals(testUltimateParent.Id,theAcnt.Ultimate_Parent__c);
        }
        
    }
    
    @istest
    public static void testTestTwoTierHierarchyModifyingTeir2HierarchyLevel(){
        
        Account testUltimateParent = [SELECT id, Name FROM Account WHERE Name= 'TestTwoTierHierarchyModifyingTier2 - Ultimate Parent'];
        
        //Create SubParent Account
        Account testSubParent = new Account();
        testSubParent.Name = 'TestTwoTierHierarchyModifyingTier1 - Sub-Parent';
        testSubParent.Type = 'Division';
        testSubParent.ParentId = testUltimateParent.Id;
        insert testSubParent;
        
        //Create Child Account
        Account testChildAccount = new Account();
        testChildAccount.Name = 'TestTwoTierHierarchyModifyingTier1 - ChildAccount';
        testChildAccount.Type = 'Practice Location';
        testChildAccount.ParentId = testSubParent.Id;
        insert testChildAccount;   
        
        test.startTest();
        //remove ultimate parent
        testSubParent.Ultimate_Parent__c = null;
        update testSubParent;
        
        // add it back
        testSubParent.Ultimate_Parent__c = testUltimateParent.Id;
        update testSubParent;
        test.stopTest();
        
        List<Account> testAccountHiearchyList = [SELECT Id, ParentId, Ultimate_Parent__c FROM Account WHERE Id =: testChildAccount.id OR Id =: testSubParent.Id];
        for(Account theAcnt : testAccountHiearchyList){
            System.assertEquals(testUltimateParent.Id,theAcnt.Ultimate_Parent__c);
        }
        
    }
    
    @istest
    public static void testFiveTierHierarchyModifyingTeir2(){
        
        List<Account> tier1 = new List<Account>();
        Tier1.add(new Account(Name = 'testModifyingTeir2 - Ultimate Parent',
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        Tier1.add(new Account(Name = 'testModifyingTeir2 - Tier2',
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        Tier1.add(new Account(Name = 'testModifyingTeir2 - Tier3',
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        Tier1.add(new Account(Name = 'testModifyingTeir2 - Tier4',
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        Tier1.add(new Account(Name = 'testModifyingTeir2 - Test Account',
                              Type = 'Prospect',         
                              Website = 'ModifyingTeir2UltimateParent.com'
                             )
                 );
        
        insert Tier1;
        
        List<Account> testAcntUpdates = new List<Account>();
        test.startTest();
        Account testAcnt = Tier1.get(1);
        testAcnt.ParentId = Tier1.get(0).Id;
        testAcntUpdates.add(testAcnt);
        
        Account testAcnt1 = Tier1.get(2);
        testAcnt1.ParentId = Tier1.get(1).Id;
        testAcntUpdates.add(testAcnt1);
        
        Account testAcnt2 = Tier1.get(3);
        testAcnt2.ParentId = Tier1.get(2).Id;
        testAcntUpdates.add(testAcnt2);
        
        Account testAcnt3 = Tier1.get(4);
        testAcnt3.ParentId = Tier1.get(3).Id;
        testAcntUpdates.add(testAcnt3);
        
        update testAcntUpdates;
        test.stopTest();
        
        List<Account> testAccountHiearchyList = [SELECT Id, ParentId, Ultimate_Parent__c FROM Account WHERE Id =: testAcntUpdates];
        for(Account theAcnt : testAccountHiearchyList){
            System.assertEquals(Tier1.get(0).Id,theAcnt.Ultimate_Parent__c);
        }
        
    }
    
    @isTest
    public static void testBecameSaaSCustomerAtYesterday() {
        Account testUltimateParent = new Account();
        testUltimateParent.Name = 'TestAccount - Ultimate Parent';
        testUltimateParent.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testUltimateParent.Became_a_Customer_Date__c = system.today().addDays(-1);
        insert testUltimateParent;
        
        test.startTest();
        Account testParentOne = new Account();
        testParentOne.Name = 'TestAccount - Parent One';
        testParentOne.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testParentOne.ParentId = testUltimateParent.Id;
        insert testParentOne;
        
        Account testChild = new Account();
        testChild.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testChild.Name = 'TestAccount - Child One';
        testChild.ParentId = testParentOne.Id;
        testChild.Became_a_Customer_Date__c = system.today();
        insert testChild;
        
        Account testChildTwo = new Account();
        testChildTwo.Name = 'TestAccount - Child Two';
        testChildTwo.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testChildTwo.ParentId = testParentOne.Id;
        insert testChildTwo;
        test.stopTest();
        
        Account testAssertion = [SELECT Id, Became_a_Customer_Date__c FROM Account WHERE Id =: testChildTwo.Id];
        //Assertion
        System.assertEquals(testUltimateParent.Became_a_Customer_Date__c, testAssertion.Became_a_Customer_Date__c);
    }  
    
    @isTest
    public static void testBecameSaaSCustomerAtOldestDate() {
        
        Account testUltimateParent = new Account();
        testUltimateParent.Name = 'TestAccount - Ultimate Parent';
        testUltimateParent.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        insert testUltimateParent;
        
        test.startTest();
        Account testParentOne = new Account();
        testParentOne.Name = 'TestAccount - Parent One';
        testParentOne.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testParentOne.ParentId = testUltimateParent.Id;
        insert testParentOne;
        
        Account testChild = new Account();
        testChild.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testChild.Name = 'TestAccount - Child One';
        testChild.ParentId = testParentOne.Id;
        testChild.Became_a_Customer_Date__c = system.today();
        insert testChild;
        
        Account testGrandChildOne = new Account();
        testGrandChildOne.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testGrandChildOne.Name = 'TestAccount - Grand Child One';
        testGrandChildOne.ParentId = testChild.Id;
        insert testGrandChildOne;
        
        Account testChildTwo = new Account();
        testChildTwo.Name = 'TestAccount - Child Two';
        testChildTwo.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testChildTwo.ParentId = testParentOne.Id;
        insert testChildTwo;
        test.stopTest();
        
        List<Account> testAssertionList = [SELECT Id, Name, Became_a_Customer_Date__c FROM Account WHERE Id =: testChildTwo.Id OR Id =: testUltimateParent.Id OR Id =: testParentOne.Id];
        //Assertion
        for(Account testAcnt : testAssertionList){
            System.assertEquals(system.today(), testAcnt.Became_a_Customer_Date__c);
        }
    }  
    
    @isTest
    public static void testUpdateHieararchyLevel() {
        
        Account testUltimateParent = new Account();
        testUltimateParent.Name = 'TestAccount - Ultimate Parent';
        testUltimateParent.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        insert testUltimateParent;
        
        test.startTest();
        Account testParentOne = new Account();
        testParentOne.Name = 'TestAccount - Parent One';
        testParentOne.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testParentOne.ParentId = testUltimateParent.Id;
        insert testParentOne;
        
        Account testChild = new Account();
        testChild.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testChild.Name = 'TestAccount - Child One';
        testChild.ParentId = testParentOne.Id;
        testChild.Became_a_Customer_Date__c = system.today();
        insert testChild;
        
        Account testGrandChildOne = new Account();
        testGrandChildOne.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testGrandChildOne.Name = 'TestAccount - Grand Child One';
        testGrandChildOne.ParentId = testChild.Id;
        insert testGrandChildOne;
        
        Account testChildTwo = new Account();
        testChildTwo.Name = 'TestAccount - Child Two';
        testChildTwo.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testChildTwo.ParentId = testParentOne.Id;
        insert testChildTwo;
        test.stopTest();
        
        List<Account> testAssertionList = [SELECT Id, Hierarchy_Level__c, Name, Became_a_Customer_Date__c FROM Account WHERE Id =: testChildTwo.Id OR Id =: testUltimateParent.Id OR Id =: testParentOne.Id];
        //Assertion
        for(Account testAcnt : testAssertionList){
            if(testAcnt.Id == testUltimateParent.Id){
                System.assertEquals(testAcnt.Hierarchy_Level__c, 1);
            }else if(testAcnt.Id == testChildTwo.Id){
                System.assertEquals(testAcnt.Hierarchy_Level__c, 3);
            }
            System.assertEquals(system.today(), testAcnt.Became_a_Customer_Date__c);
        }
    }  
    
    
    @isTest
    public static void testUpdateTotalChildLocation() {
        
        Account testUltimateParent = new Account();
        testUltimateParent.Name = 'TestAccount - Ultimate Parent';
        testUltimateParent.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        insert testUltimateParent;
        
        test.startTest();
        Account testParentOne = new Account();
        testParentOne.Name = 'TestAccount - Parent One';
        testParentOne.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testParentOne.ParentId = testUltimateParent.Id;
        insert testParentOne;
        
        Account testChild = new Account();
        testChild.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testChild.Name = 'TestAccount - Child One';
        testChild.ParentId = testUltimateParent.Id;
        testChild.Became_a_Customer_Date__c = system.today();
        testChild.Type = 'Practice Location';
        insert testChild;
        
        Account testGrandChildOne = new Account();
        testGrandChildOne.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testGrandChildOne.Name = 'TestAccount - Grand Child One';
        testGrandChildOne.ParentId = testUltimateParent.Id;
        insert testGrandChildOne;
        
        Account testChildTwo = new Account();
        testChildTwo.Name = 'TestAccount - Child Two';
        testChildTwo.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        testChildTwo.ParentId = testUltimateParent.Id;
        testChildTwo.Type = 'Practice Location';
        insert testChildTwo;
        test.stopTest();
        
        Account testUltimateParentAssert = [SELECT Id, Hierarchy_Level__c, Total_Child_Locations__c, Name, Became_a_Customer_Date__c FROM Account WHERE Id =: testUltimateParent.Id];
        //Assertion
        system.assertEquals(2, testUltimateParentAssert.Total_Child_Locations__c);
    }  
}