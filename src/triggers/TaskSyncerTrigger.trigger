trigger TaskSyncerTrigger on Task(after insert, after update, before delete) {
    if(trigger.isInsert) {
        MilestoneTaskSyncer.syncTaskInsertTrigger(trigger.new);
    }
    else if(trigger.isUpdate) {
        MilestoneTaskSyncer.syncTaskUpdateTrigger(trigger.new, trigger.old);
    }
    else if(trigger.isDelete) {
        MilestoneTaskSyncer.syncTaskDeleteTrigger(trigger.old);
    }
}