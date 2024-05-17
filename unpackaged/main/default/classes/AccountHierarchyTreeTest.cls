/**********************************************************
Class: AccountHierarchyTreeTest 
LastModifiedBy: Bopsy 03/13/2023
Description: Test Class for AccountHierarchyTree 
***********************************************************/
@isTest
public class AccountHierarchyTreeTest {
   
    @isTest
    public static void addRootNodeConstructorUnitTest() {
        
        Account testAcnt = new Account(Name = 'testAccount',Id='001000000075dhj');
        AccountHierarchyTree tree;
        
        test.startTest();
          tree = new AccountHierarchyTree(testAcnt);
        test.stopTest();
        
        List<Account> treeAccounts = tree.getAccounts();
        System.assertEquals(treeAccounts.size(),1);
        System.assertEquals(treeAccounts.get(0).id,tree.getRoot().id);
        System.assertEquals(testAcnt.id,tree.getRoot().id);
        System.assertEquals(tree.getDepth(), 1);
        System.assertNotEquals(treeAccounts.get(0).Ultimate_Parent__c,testAcnt.id);
    }
    
    @isTest
    public static void addSecondNodeChildUnitTest(){
        
        Account rootAcct = new Account(Name='root',Id='00100000005nduk');
        Account childAcct = new Account(Name='child',Id='0010000000wjheg',ParentId='00100000005nduk');
        
        AccountHierarchyTree tree; 
        
        test.startTest();
          tree = new AccountHierarchyTree(rootAcct);
          tree.addNode(childAcct);
        test.stopTest();
        
        List<Account> accts = tree.getAccounts();
        System.assertEquals(accts.size(),2);
        System.assertEquals(rootAcct.id,tree.getRoot().id);
        System.assertEquals(tree.getDepth(), 2);
    }
    
    @isTest
    public static void addSecondNodeWithTwoChildrenUnitTest(){
        
        Account rootAcct = new Account(Name='root',Id='00100000005nduk');
        Account firstChildAcct = new Account(Name='first child',Id='0010000000wjheg',ParentId='00100000005nduk');
        Account secondChildAcct = new Account(Name='second child',Id='0010000000isj4f',ParentId='00100000005nduk');
        
        AccountHierarchyTree tree = new AccountHierarchyTree(rootAcct);
        
        test.startTest();
          tree.addNode(firstChildAcct);
          tree.addNode(secondChildAcct);
        test.stopTest();
        
        List<Account> accts = tree.getAccounts();
        System.assertEquals(accts.size(),3);
        System.assertEquals(rootAcct.id,tree.getRoot().id);
        System.assertEquals(tree.getDepth(), 2);
        System.assertEquals(tree.getNumberOfNodes(), 3);
    }
    
    @isTest
    public static void addSecondNodeParentUnitTest(){
        
        Account rootAcct = new Account(Name='root',Id='00100000005nduk');
        Account childAcct = new Account(Name='first child',Id='0010000000wjheg',ParentId='00100000005nduk');
        Account grandchildAcct = new Account(Name='grand child',Id='0010000000isj4f',ParentId='0010000000wjheg');
        
        AccountHierarchyTree tree = new AccountHierarchyTree(childAcct);
        
        test.startTest();
          tree.addNode(grandchildAcct);
          tree.addNode(rootAcct);
        test.stopTest();
        
        List<Account> accts = tree.getAccounts();
        System.assertEquals(accts.size(),3);
        System.assertEquals(rootAcct.id,tree.getRoot().id);
        System.assertEquals(tree.getDepth(), 3);
    }
    
    @isTest
    public static void addSecondNodeParentUnitTestWithAdditionalDepthTest(){
        
        Account rootAcct = new Account(Name='root',Id='00100000005nduk');
        Account childAcct = new Account(Name='first child',Id='0010000000wjheg',ParentId='00100000005nduk');
        Account grandchildAcct = new Account(Name='grand child',Id='0010000000isj4f',ParentId='0010000000wjheg');
        
        AccountHierarchyTree tree = new AccountHierarchyTree(childAcct);
        
        test.startTest();
          tree.addNode(grandchildAcct);
          tree.addNode(rootAcct);
        test.stopTest();
        
        List<Account> accts = tree.getAccounts();
        System.assertEquals(accts.size(),3);
        System.assertEquals(rootAcct.id,tree.getRoot().id);
        System.assertEquals(tree.getDepth(), 3);
        System.assertEquals(tree.getDepth(childAcct.id), 2);
    }
    
    @isTest
    public static void addThirdNodeParentUnitTest(){
        Account rootAcct = new Account(Name='root',Id='00100000005nduk');
        Account childAcct = new Account(Name='first child',Id='0010000000wjheg',ParentId='00100000005nduk');
        Account secondChildAcct = new Account(Name='second child',Id='0010000000ikjdh',ParentId='00100000005nduk');
        Account grandChildAcct = new Account(Name='grand child',Id='0010000000isj4f',ParentId='0010000000wjheg');
        Account greatGrandChildAcct = new Account(Name='great child',Id='00100000003kj4h',ParentId='0010000000isj4f');
        
        AccountHierarchyTree tree = new AccountHierarchyTree(childAcct);
        
        test.startTest();
          tree.addNode(grandchildAcct);
          tree.addNode(rootAcct);
          tree.addNode(secondChildAcct);
          tree.addNode(greatGrandChildAcct);
        test.stopTest();
        
        List<Account> accts = tree.getAccounts();
        System.assertEquals(accts.size(),5);
        System.assertEquals(rootAcct.id,tree.getRoot().id);
        System.assertEquals(tree.getDepth(), 4);
        System.assertEquals(tree.getNumberOfNodes(),5);
    }
    
    @isTest
    public static void mergeOneNodeTreesUnitTest(){
        Account rootAcct = new Account(Name='root',Id='00100000005nduk');
        Account childAcct = new Account(Name='first child',Id='0010000000wjheg',ParentId='00100000005nduk');
        
        AccountHierarchyTree tree = new AccountHierarchyTree(rootAcct);
        AccountHierarchyTree tree2 = new AccountHierarchyTree(childAcct);
        
        test.startTest();
          tree.mergeTrees(tree2);
        test.stopTest();
        
        List<Account> accts = tree.getAccounts();
        System.assertEquals(accts.size(),2);
        System.assertEquals(rootAcct.id,tree.getRoot().id);
        System.assertEquals(tree.getDepth(), 2);
        System.assertEquals(tree.getNumberOfNodes(),2);
    }
    
    @isTest
    public static void mergeDifferentNodeTreesUnitTest(){
        Account rootAcct = new Account(Name='root',Id='00100000005nduk');
        Account childAcct = new Account(Name='first child',Id='0010000000wjheg',ParentId='00100000005nduk');
        Account secondChildAcct = new Account(Name='second child',Id='0010000000ikjdh',ParentId='00100000005nduk');
        Account grandChildAcct = new Account(Name='grand child',Id='0010000000isj4f',ParentId='0010000000wjheg');
        Account greatGrandChildAcct = new Account(Name='great child',Id='00100000003kj4h',ParentId='0010000000isj4f');
        
        AccountHierarchyTree tree = new AccountHierarchyTree(childAcct);
        tree.addNode(rootAcct);
         tree.addNode(secondChildAcct);
        
        AccountHierarchyTree tree2 = new AccountHierarchyTree(grandChildAcct);
        tree2.addNode(greatGrandChildAcct);
        
        test.startTest();
          tree.mergeTrees(tree2);
        test.stopTest();
        
        List<Account> accts = tree.getAccounts();
        System.assertEquals(accts.size(),5);
        System.assertEquals(rootAcct.id,tree.getRoot().id);
        System.assertEquals(tree.getDepth(), 4);
        System.assertEquals(tree.getNumberOfNodes(),5);
    }
    
    @isTest
    public static void populateUltimateUnitTest(){
        Account rootAcct = new Account(Name='root',Id='00100000005nduk');
        Account childAcct = new Account(Name='first child',Id='0010000000wjheg',ParentId='00100000005nduk');
        Account secondChildAcct = new Account(Name='second child',Id='0010000000ikjdh',ParentId='00100000005nduk');
        Account grandChildAcct = new Account(Name='grand child',Id='0010000000isj4f',ParentId='0010000000wjheg');
        Account greatGrandChildAcct = new Account(Name='great child',Id='00100000003kj4h',ParentId='0010000000isj4f');
        
        AccountHierarchyTree tree = new AccountHierarchyTree(childAcct);
        tree.addNode(rootAcct);
         tree.addNode(secondChildAcct);
        
        AccountHierarchyTree tree2 = new AccountHierarchyTree(grandChildAcct);
        tree2.addNode(greatGrandChildAcct);
        
        tree.mergeTrees(tree2);
        
        test.startTest();
          tree.populateUltimateParent();
        test.stopTest();
        
        List<Account> accts = tree.getAccounts();
        System.assertEquals(accts.size(),5);
        System.assertEquals(rootAcct.id,tree.getRoot().id);
        System.assertEquals(tree.getDepth(), 4);
        System.assertEquals(tree.getNumberOfNodes(),5);
        for(Account acct: accts){
            if(acct.id == rootAcct.id) continue;
            System.assertEquals(rootAcct.id,acct.Ultimate_Parent__c);
        }
    }
    
    @isTest
    public static void isAddableFalseUnitTest(){
        
        Account rootAcct = new Account(Name='root',Id='00100000005nduk');
        Account childAcct = new Account(Name='first child',Id='0010000000wjheg',ParentId='00100000005nduk');
        Account falseChildAcct = new Account(Name='false child',Id='0010000000isj4f',ParentId='00100000008jrhf');
        
        Test.startTest();
        AccountHierarchyTree tree = new AccountHierarchyTree(childAcct);
        Test.stopTest();
        
         System.assert(tree.isAddable(rootAcct));
        System.assert(!tree.isAddable(falseChildAcct));
    }
    
    @isTest
    public static void isAddableAfterUpdatedRootUnitTest(){
        
        Account rootAcct = new Account(Name='root',Id='00100000005nduk');
        Account childAcct = new Account(Name='first child',Id='0010000000wjheg',ParentId='00100000005nduk');
        Account falseChildAcct = new Account(Name='false child',Id='0010000000isj4f',ParentId='00100000005nduk');
        
        AccountHierarchyTree tree = new AccountHierarchyTree(childAcct);
        System.assert(tree.isAddable(rootAcct));
        System.assert(!tree.isAddable(falseChildAcct));
        
        Test.startTest();
          tree.addNode(rootAcct);
        Test.stopTest();
        
        System.assert(tree.isAddable(falseChildAcct));
    }
}