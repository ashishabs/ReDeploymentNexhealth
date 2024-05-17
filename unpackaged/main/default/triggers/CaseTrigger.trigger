/**********************************************************
Class: CaseTrigger
LastModifiedBy: Bopsy 03/21/2022
Description: This is trigger class for the CaseTriggerHandler 
***********************************************************/
trigger CaseTrigger on Case (After insert, After Update, before insert, before update) {
    
    if(trigger.isafter) {
        CaseTriggerHandler.stampAccountfieldsWithCases(trigger.new,trigger.oldmap);
        
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
            CaseTriggerHandler.unlockCaseRecordFromApproval(trigger.new);
        }
        
        
    }
    
    if(trigger.isBefore && trigger.isInsert) {
        CaseTriggerHandler.updateBusinessHoursCheckbox(trigger.new);
    }

    if(trigger.isAfter && trigger.isUpdate){
        CustomerObjectives.HandleOnboardingCaseTrigger(trigger.new, trigger.oldmap);
    }
    
    if(trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        CaseTriggerHandler.callCustomerLifecycleQueuable(trigger.new);
    }
}