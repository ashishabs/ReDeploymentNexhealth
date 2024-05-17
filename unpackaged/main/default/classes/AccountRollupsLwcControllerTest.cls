/**********************************************************
Class: AccountRollupsLwcControllerTest
LastModifiedBy: Cloud Connex 04/19/2023
Description: This is Test class for the AccountRollupsLwcController     
***********************************************************/
@istest
public class AccountRollupsLwcControllerTest {
    
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
        
        insert Tier1;
        
        Tier2.add(new Account(Name = 'Tier 2 Child 1 Tree 1',
                              ParentId = Tier1.get(0).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com',
                              Ultimate_Parent__c = Tier1.get(0).Id
                             )
                 );
        
        Tier2.add(new Account(Name = 'Tier 2 Child 2 Tree 1',
                              ParentId = Tier1.get(0).Id,
                              Type = 'Prospect',         
                              Website = 'UltimateParent.com',
                              Ultimate_Parent__c = Tier1.get(0).Id
                             )
                 );
        
        insert Tier2;
        
    }
    
    @istest
    public static void testAccountRollupsFromChildTier2Child1Tree1(){
        
        Account testAccount = [Select Name, Id, ParentId, Ultimate_Parent__c From Account Where Name='Tier 2 Child 1 Tree 1'];
        
        AccountRollupsLwcController.WrapperForHierarchyDetails testWrapDetails;
        test.startTest();
        testWrapDetails = AccountRollupsLwcController.fetchHierarchyDetails(testAccount.Id);
        test.stopTest();
        
        system.assertEquals(0, testWrapDetails.RiskLocationCountApex);
        system.assertEquals(0, testWrapDetails.OpenSupportCasesCountApex);
        system.assertEquals(0, testWrapDetails.PracticeLocationCountApex);
    }
    
    @istest
    public static void testAccountRollupsFromChildRecord(){
        
        Account testAccount = [Select Name, Id, ParentId, Ultimate_Parent__c From Account Where Name='Tier 2 Child 1 Tree 1'];
        testAccount.Account_Risk_Level__c = 'Medium';
        update testAccount;
        
        AccountRollupsLwcController.WrapperForHierarchyDetails testWrapDetails;
        test.startTest();
        testWrapDetails = AccountRollupsLwcController.fetchHierarchyDetails(testAccount.Id);
        test.stopTest();
        
        system.assertEquals(1, testWrapDetails.RiskLocationCountApex);
        system.assertEquals(0, testWrapDetails.OpenSupportCasesCountApex);
        system.assertEquals(0, testWrapDetails.PracticeLocationCountApex);
    }
    
    @istest
    public static void testAccountRollupsFromUltimateParent(){
        
        Account testAccount = [Select Name, Id, ParentId, Ultimate_Parent__c From Account Where Name='Ultimate Parent Tree 1'];
        testAccount.Account_Risk_Level__c = 'High';
        update testAccount;
        
        AccountRollupsLwcController.WrapperForHierarchyDetails testWrapDetails;
        test.startTest();
        testWrapDetails = AccountRollupsLwcController.fetchHierarchyDetails(testAccount.Id);
        test.stopTest();
        
        system.assertEquals(1, testWrapDetails.RiskLocationCountApex);
        
    }
    
    @istest
    public static void testAccountRollupsFromUltimateParentWithLowRisk(){
        
        Account testAccount = [Select Name, Id, ParentId, Ultimate_Parent__c From Account Where Name='Ultimate Parent Tree 1'];
        testAccount.Account_Risk_Level__c = 'Low';
        update testAccount;
        
        AccountRollupsLwcController.WrapperForHierarchyDetails testWrapDetails;
        test.startTest();
        testWrapDetails = AccountRollupsLwcController.fetchHierarchyDetails(testAccount.Id);
        test.stopTest();
        
        system.assertEquals(0, testWrapDetails.RiskLocationCountApex);
        
    }
    
    @istest
    public static void testAccountRollupsFromUltimateParentWithLowPracticeLocation(){
        
        Account testAccount = [Select Name, Id, ParentId, Ultimate_Parent__c From Account Where Name='Ultimate Parent Tree 1'];
        testAccount.Type = 'Practice Location';
        update testAccount;
        
        AccountRollupsLwcController.WrapperForHierarchyDetails testWrapDetails;
        test.startTest();
        testWrapDetails = AccountRollupsLwcController.fetchHierarchyDetails(testAccount.Id);
        test.stopTest();
        
        system.assertEquals(1, testWrapDetails.PracticeLocationCountApex);
        
    }
}