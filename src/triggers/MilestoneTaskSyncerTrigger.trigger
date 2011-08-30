trigger MilestoneTaskSyncerTrigger on Milestone1_Task__c(after insert, after update, before delete) { 
    if(trigger.isInsert) {
        MilestoneTaskSyncer.handleInsertTaskTrigger(trigger.new);
    }
    else if(trigger.isUpdate) {
        MilestoneTaskSyncer.handleUpdateTaskTrigger(trigger.new, trigger.old);
    }
    else if(trigger.isDelete) {
        MilestoneTaskSyncer.handleDeleteTaskTrigger(trigger.old);
    }
}