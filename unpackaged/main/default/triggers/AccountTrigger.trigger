trigger AccountTrigger on Account (After insert, After Update) {
    
    if(trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        AccountTriggerHandler.updateAccountUltimateParent(trigger.new,trigger.oldMap);
    }
}