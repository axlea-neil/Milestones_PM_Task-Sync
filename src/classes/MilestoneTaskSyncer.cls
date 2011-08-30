public class MilestoneTaskSyncer {

    /*
     *  Handles operations after an Insert operation in a PM Task.
     *
     *  This method creates a standard Task record that is related to the Milestone PM Task
     *  record involved.
     */
    public static void handleInsertTaskTrigger(List<Milestone1_Task__c> newList) {
        List<Task> taskList = new List<Task>();
        
        for(Milestone1_Task__c task : newList) {
            // Check for recursive action
            if(!task.insert_standard_task__c) {
                continue;
            }
            Task t = new Task(activityDate = task.due_date__c,
                              whatid = task.Id,
                              ownerid = task.assigned_to__c,
                              update_pm_task__c = false
                    );
            taskList.add(t);
        }
        
        insert taskList;
    }
    
    /*
     *  Handles operations after an Update operation in a PM Task.
     *  
     *  This method updates the common fields of the standard Task record and the Milestone PM Task
     *  record that is related to the Milestone PM Task record involved.
     *
     *  The following are the common fields:
     *  1.  Assigned to field
     *      - Label for Task object is Assigned To.
     *        Field name is Owner.
     *      - Label for PM Task object is Assigned To.
     *        Field name is assigned_to__c
     *  2.  Due Date
     *      - Label for Task object is Due Date.
     *        Field name is ActivityDate.
     *      - Label for PM Task object is Due Date.
     *        Field name if due_date__c.
     *
     *  The following fields are not included eventhough these fields are common to both objects.
     *  1.  Priority
     *      - Standard object Task and PM Task have different set of picklist values.
     *  2.  Email
     *      - Different field type
     *      - Standard object Task has an Email field type.
     *      - PM Task has a Text External Id type.
     *      - PM Task has a different label (Email_GUID).
     */
    public static void handleUpdateTaskTrigger(List<Milestone1_Task__c> newList, List<Milestone1_Task__c> oldList) {
        List<Task> taskList = new List<Task>();
        
        for(Milestone1_Task__c task : newList) {
            // Check for recursive action
            if(!task.update_standard_task__c) {
                continue;
            }
            Task t;
            try {
                t = [SELECT id, ownerId, activityDate
                     FROM Task
                     WHERE whatId = :task.Id][0];
                t.ownerId = task.assigned_to__c;
                t.activityDate = task.due_date__c;
                t.update_pm_task__c = false;
            }catch(System.ListException e) {
                t = null;
            }
            if(t != null) {
                taskList.add(t);
            }
        }
        
        update taskList;
    }
    
    /*
     *  Handles operations after a delete operation in a PM Task.
     *
     *  This method deletes the Standard object Task related to the PM Task.
     */
    public static void handleDeleteTaskTrigger(List<Milestone1_Task__c> oldList) {
        List<Task> taskList = new List<Task>();
        
        for(Milestone1_Task__c task : oldList) {
            // Check for recursive action
            if(!task.delete_standard_task__c) {
                continue;
            }
            Task t;
            try {
                t = [SELECT id
                     FROM Task
                     WHERE whatId = :task.Id][0];
                t.delete_PM_task__c = false;
                t.update_PM_task__c = false;
            }catch(System.ListException e) {
                t = null;
            }
            if(t != null) {
                taskList.add(t);
            }
        }
        
        /*
         * Update the delete_PM_task__c field of Tasks to delete before deleting to prevent
         * recursive delete.
         */
        update taskList;
        
        // Delete updated task list
        taskList = [SELECT id
                    FROM Task
                    WHERE delete_PM_task__c = false
                    AND update_PM_task__c = false];
        delete taskList;
    }
    
    /*
     *  Handles operations after an insert operation in the standard object Task.
     *
     *  This method checks if the related to field of the Task object is a PM Task.
     *  Updates the fields of the PM Task that are common with the fields of the
     *  newly created Standard object task.
     */
    public static void syncTaskInsertTrigger(List<Task> newList) {
        updateTaskList(newList, 'insert');
        
    }
    
    /*
     *  Handles operations after an update operation in the standard object Task.
     *
     *  This method checks if the related to field of the Task object is a PM Task.
     *  Updates the fields of the PM Task that are common with the fields of the
     *  newly created Standard object task.
     */
    public static void syncTaskUpdateTrigger(List<Task> newList, List<Task> oldList) {
        updateTaskList(newList, 'update');
    }
    
    /*
     *  Handles operations after a delete operation in the standard object Task.
     *
     *  This method checks if the related to field of the Task object is a PM Task.
     *  Deletes the subsequent PM Task associated with the Standard object Task.
     */
    public static void syncTaskDeleteTrigger(List<Task> oldList) {
        List<Milestone1_Task__c>  taskList = getTaskList(oldList, 'delete');
        /*
         * Update the delete_standard_task__c field of Milestone1_Task__c to delete 
         * before deleting to prevent recursive delete.
         */
        update taskList;

        //Set of list ids of related tasks of standard object task
        Set<Id> taskIdSet = new Set<Id>();
        for(Task t : oldList) {
            taskIdSet.add(t.whatId);
            System.debug('Task Id Set = ' + t.whatId);
        }
        
        // Delete updated task list
        taskList = [SELECT id
                    FROM Milestone1_Task__c
                    WHERE delete_standard_task__c = false
                    AND update_standard_task__c = false
                    AND id in :taskIdSet];
        for(Milestone1_Task__c t : taskList) {
            System.debug('PM Task Id(before delete) = ' + t.id);
        }
        delete taskList;
    }
    
    //Utility methods
    private static List<Milestone1_Task__c> getTaskList(List<Task> tList, String operation) {
        System.debug('operation = ' + operation);
        List<Milestone1_Task__c>  taskList = new List<Milestone1_Task__c>();
    
        for(Task task : tList) {
            // Check for recursive action
            if(!task.delete_PM_task__c && operation == 'delete') {
                continue;
            }
            if(!task.update_PM_task__c && (operation == 'insert' || operation == 'update')) {
                continue;
            }
            Milestone1_Task__c t;
            try {
                t = [SELECT id, assigned_to__c, due_date__c, delete_standard_task__c, update_standard_task__c, insert_standard_task__c
                     FROM Milestone1_Task__c
                     WHERE id = :task.whatId][0];
            }catch(System.ListException e) {
                t = null;
            }
            if(t != null) {
                t.assigned_to__c = task.ownerId;
                t.due_date__c = task.activityDate;
                if(operation == 'delete') {
                    t.delete_standard_task__c = false;
                    t.update_standard_task__c = false;
                }
                else if(operation == 'insert') {
                    t.insert_standard_task__c = false;
                }
                else if(operation == 'update') {
                    t.update_standard_task__c = false;
                }
                taskList.add(t);
            }
        }
        
        return taskList;
    }
    
    private static void updateTaskList(List<Task> newList, String operation) {
        List<Milestone1_Task__c>  taskList = getTaskList(newList, operation);
        update taskList;
    }

}