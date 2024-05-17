/**********************************************************
Class: BatchUltimateParentPopulateAccountsTest
LastModifiedBy: Cloud Connex 05/04/2023
Description: This is Test class for the BatchUltimateParentPopulateAccounts     
***********************************************************/
@istest
public class BatchUltimateParentPopulateAccountsTest {
    
    @testSetup
    public static void setup() {  
        
        List<Account> tier1 = new List<Account>();
        List<Account> tier2 = new List<Account>();
        List<Account> tier3 = new List<Account>();
        List<Account> tier4 = new List<Account>();
        List<Account> tier5 = new List<Account>();
        List<Account> tier6 = new List<Account>();
        
        Tier1.add(new Account(Name = 'Ultimate Parent Tree 1',
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        Tier1.add(new Account(Name = 'Ultimate Parent Tree 2',
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        Tier1.add(new Account(Name = 'Ultimate Parent Tree 3',
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        Tier1.add(new Account(Name = 'Ultimate Parent Tree 4',
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        insert Tier1;
        
        Tier2.add(new Account(Name = 'Tier 2 Child 1 Tree 1',
                              ParentId = Tier1.get(0).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        Tier2.add(new Account(Name = 'Tier 2 Child 2 Tree 1',
                              ParentId = Tier1.get(0).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        Tier2.add(new Account(Name = 'Tier 2 Child 1 Tree 2',
                              ParentId = Tier1.get(1).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        Tier2.add(new Account(Name = 'Tier 2 Child 1 Tree 3',
                              ParentId = Tier1.get(2).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                  
                 );
        
        insert Tier2;
        
        tier3.add(new Account(Name = 'Tier 3 Child 3 Tree 1',
                              ParentId = Tier2.get(1).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        tier3.add(new Account(Name = 'Tier 3 Child 2 Tree 2',
                              ParentId = Tier2.get(2).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        insert tier3;
        
        tier4.add(new Account(Name = 'Tier 4 Child 4 Tree 1',
                              ParentId = tier3.get(0).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        tier4.add(new Account(Name = 'Tier 4 Child 3 Tree 2',
                              ParentId = tier3.get(1).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        tier4.add(new Account(Name = 'Tier 4 Child 4 Tree 2',
                              ParentId = tier3.get(1).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        insert tier4;
        
        tier5.add(new Account(Name = 'Tier 5 Child 5 Tree 1',
                              ParentId = tier4.get(0).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        tier5.add(new Account(Name = 'Tier 5 Child 6 Tree 1',
                              ParentId = tier4.get(0).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        tier5.add(new Account(Name = 'Tier 5 Child 5 Tree 2',
                              ParentId = tier4.get(2).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        
        insert tier5;
        
        tier6.add(new Account(Name = 'Tier 6 Child 7 Tree 1',
                              ParentId = tier5.get(1).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com'
                             )
                 );
        insert tier6;
        
        
    }
    
    @isTest
    public static void TestNoHierarchy() {
        
        Account testAccount = [Select id,Name From Account Where Name='Ultimate Parent Tree 4'];
        testAccount.Hierarchy_Adjusted__c = True;
        testAccount.type = 'Practice Location';
        update testAccount;
        
        test.startTest();
        Database.executeBatch(new BatchUltimateParentPopulateAccounts(), 200);
        test.stopTest();
        
        testAccount = [SELECT Id, ParentId, Hierarchy_Level__c, Total_Child_Locations__c FROM Account WHERE Id =: testAccount.id];
        System.assertEquals(1, testAccount.Hierarchy_Level__c);
        System.assertEquals(1,testAccount.Total_Child_Locations__c);
        
    }
    
    @isTest
    public static void TestTwoTierHierarchyModifyingTeir1() {
        
        Account testAccount = [Select Id, Name From Account Where Name='Ultimate Parent Tree 3'];
        testAccount.Hierarchy_Adjusted__c = true;
        update testAccount;
        
        test.startTest();
        Database.executeBatch(new BatchUltimateParentPopulateAccounts(), 200);
        test.stopTest();
        
        List<Account> tree3childrensList = [SELECT Id, Hierarchy_Level__c, Total_Child_Locations__c FROM Account WHERE Ultimate_Parent__c =: testAccount.Id];
        for(Account child: tree3childrensList){
            System.assertNotEquals(0, child.Hierarchy_Level__c);
        }
        
    }
    
    @isTest
    public static void SchedulableWithoutAdjusted() {
        String testQuery = 'SELECT Id, Name, ParentId, Ultimate_Parent__c, Type, Hierarchy_Level__c, Hierarchy_Adjusted__c, Total_Child_Locations__c FROM Account WHERE Ultimate_Parent__c = null AND Hierarchy_Adjusted__c = true';
        BatchUltimateParentPopulateAccounts testBatch = new BatchUltimateParentPopulateAccounts(testQuery);
        test.startTest();
        testBatch.execute(null);
        test.stopTest();
        
        Account testAccount = [SELECT Id, Hierarchy_Level__c, Total_Child_Locations__c FROM Account WHERE Name = 'Ultimate Parent Tree 4'];
        System.assertEquals(null, testAccount.Hierarchy_Level__c);
        System.assertEquals(null,testAccount.Total_Child_Locations__c);
    }
    
}