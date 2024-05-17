trigger OpportunityTrigger on Opportunity (Before insert, Before update, after insert, after update, after delete) {
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        
        OpportunityTriggerhandler.UpdateAccountRecordType(trigger.new, trigger.oldmap);
        OpportunityTriggerhandler.updateAccountAndContactsWithActiveDeveloperStatus(trigger.new, trigger.oldmap);
        OpportunityTriggerhandler.updateOCRContactDate(trigger.new, trigger.oldmap);
        
    } 
    
    if(Trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        OpportunityTriggerhandler.updateAccountTimeStampFields(trigger.new,trigger.oldMap);
    }
    
    if(Trigger.isAfter && trigger.isDelete) {
        OpportunityTriggerhandler.updateAccountTimeStampFields(trigger.old,null);
    }
    
    if(Trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
        OpportunityTriggerhandler.OppInstallCompleteEmailNotification(trigger.new, trigger.oldmap);
    }
    
    if(Trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        OpportunityTriggerhandler.CreateTaskFromOpportunity(trigger.new, trigger.oldmap);
    }
    
    if(trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        OpportunityTriggerhandler.callCustomerLifecycleQueuable(trigger.new, trigger.oldmap);
    }
    
    if(Trigger.isBefore && trigger.isInsert) {
        OpportunityTriggerhandler.checkandAddErrorOnUpsellOpportunity(trigger.new);
    }
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        OpportunityTriggerhandler.unlockOppRecordFromApproval(trigger.new);
    }
}