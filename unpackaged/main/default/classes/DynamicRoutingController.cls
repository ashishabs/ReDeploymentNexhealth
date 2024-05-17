public with sharing class DynamicRoutingController {
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getFieldSetInfo() {
        List<Map<String, String>> fieldSetInfo = new List<Map<String, String>>();
        
        Schema.FieldSet fs = Schema.SObjectType.Permission__c.FieldSets.DynamicRouting;
        for(Schema.FieldSetMember f : fs.getFields()) {
            Map<String, String> fieldMap = new Map<String, String>();
            fieldMap.put('label', f.getLabel());
            fieldMap.put('fieldPath', f.getFieldPath());
            fieldSetInfo.add(fieldMap);
        }
        
        return fieldSetInfo;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getPermissionRecords(String caseId) {
        List<Map<String, Object>> theReturnPermissionRecordsList = new List<Map<String, Object>>();
        
        Case theCase = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.Ultimate_Parent__c FROM Case WHERE Id = :caseId];
        
        if (theCase != null && theCase.Contact.AccountId != null && theCase.Contact.Account.Ultimate_Parent__c != null) {
            List<Assigned_Permission__c> theAssignedPermissionsList = [SELECT Id, Permission__c FROM Assigned_Permission__c WHERE Assigned_Contact__c = :theCase.ContactId];
            Set<Id> thePermissionIds = new Set<Id>();
            for (Assigned_Permission__c theAssignedPerm : theAssignedPermissionsList) {
                thePermissionIds.add(theAssignedPerm.Permission__c);
            }
            
            String dynamicQuery = 'SELECT Id';
            for (Map<String, String> fieldMap : getFieldSetInfo()) {
                dynamicQuery += ', ' + fieldMap.get('fieldPath');
            }
            
            if(thePermissionIds != null){
                dynamicQuery += ' FROM Permission__c WHERE Id IN :thePermissionIds AND Account__c = \'' + theCase.Contact.Account.Ultimate_Parent__c + '\'';
                
                List<SObject> theSoqlPermissionList = Database.query(dynamicQuery);
                for(SObject theSOQLPerm : theSoqlPermissionList) {
                    Map<String, Object> theRecordMap = new Map<String, Object>();
                    for (Map<String, String> fieldMap : getFieldSetInfo()) {
                        theRecordMap.put(fieldMap.get('fieldPath'), theSOQLPerm.get(fieldMap.get('fieldPath')));
                    }
                    theReturnPermissionRecordsList.add(theRecordMap);
                }
            }
            
        }
        return theReturnPermissionRecordsList;
    }
    
}