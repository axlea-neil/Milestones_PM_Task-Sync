trigger TaskSyncerTrigger on Task(after insert, after update, before delete) {
    if(trigger.isInsert) {
        Milestone1_Ext_TaskSyncer.syncTaskInsertTrigger(trigger.new);
    }
    else if(trigger.isUpdate) {
        Milestone1_Ext_TaskSyncer.syncTaskUpdateTrigger(trigger.new, trigger.old);
    }
    else if(trigger.isDelete) {
        Milestone1_Ext_TaskSyncer.syncTaskDeleteTrigger(trigger.old);
    }
}