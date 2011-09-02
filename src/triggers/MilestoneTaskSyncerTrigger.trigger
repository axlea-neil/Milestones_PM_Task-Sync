trigger Milestone1_TaskSyncerTrigger on Milestone1_Task__c(after insert, after update, before delete) { 
    if(trigger.isInsert) {
        Milestone1_TaskSyncer.handleInsertTaskTrigger(trigger.new);
    }
    else if(trigger.isUpdate) {
        Milestone1_TaskSyncer.handleUpdateTaskTrigger(trigger.new, trigger.old);
    }
    else if(trigger.isDelete) {
        Milestone1_TaskSyncer.handleDeleteTaskTrigger(trigger.old);
    }
}