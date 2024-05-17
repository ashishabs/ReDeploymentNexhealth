@isTest
private class DynamicRoutingControllerTest {
    
    @testSetup
    static void setupTestData() {
        Account ultimateParentAccount = new Account(
            Name = 'Ultimate Parent Account',
            organization_type__c = 'Consultancy'
        );
        insert ultimateParentAccount;
        
        Account testAccount = new Account(
            Name = 'Test Account',
            Ultimate_Parent__c = ultimateParentAccount.Id,
            organization_type__c = 'Consultancy'
        );
        insert testAccount;
        
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            AccountId = testAccount.Id,
            Email = 'test@gmail.com'
        );
        insert testContact;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            ContactId = testContact.Id
        );
        insert testCase;
        
        Permission__c permissionRecord = new Permission__c(
            Name = 'Test Role',
            Online_Booking__c = 'Yes',
            X2_Way_Messaging__c = 'Yes',
            Patients__c = 'Yes',
            Payments__c = 'No',
            Campaigns__c = 'Yes',
            Forms__c = 'Yes',
            Forms_Editing__c = 'Yes',
            Account__c = ultimateParentAccount.Id 
        );
        insert permissionRecord;
        
        Assigned_Permission__c assignedPermissionRecord = new Assigned_Permission__c(
            Permission__c = permissionRecord.Id,
            Assigned_Contact__c = testContact.Id
        );
        insert assignedPermissionRecord;
    }
    
    @isTest
    static void testGetPermissionRecords() {
        
        Case testCase = [SELECT Id, ContactId FROM Case LIMIT 1];
        
        Test.startTest();
        List<Map<String, Object>> permissionRecords = DynamicRoutingController.getPermissionRecords(testCase.Id);
        Test.stopTest();
        
        System.assertEquals(1, permissionRecords.size(), 'Expected only one permission record');
        Map<String, Object> recordMap = permissionRecords[0];
        System.assertNotEquals(null, recordMap.get('Name'), 'Name field should not be null');
        System.assertNotEquals(null, recordMap.get('Online_Booking__c'), 'Online_Booking__c field should not be null');
    }
    
    @isTest
    static void testGetFieldSetInfo() {
        Test.startTest();
        List<Map<String, String>> fieldSetInfo = DynamicRoutingController.getFieldSetInfo();
        Test.stopTest();
        
        System.assertNotEquals(null, fieldSetInfo, 'Field Set info should not be null');
        System.assertNotEquals(0, fieldSetInfo.size(), 'Field Set should not be empty');
    }
}