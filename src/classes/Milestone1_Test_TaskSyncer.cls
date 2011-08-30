@istest
private class Milestone1_Test_TaskSyncer {

    /*
     *  Tests whether a Standard object Task is created after creating
     *  a PM Task.
     */
    static testmethod void testPMTaskToStandardTaskLinking() {
        // For data consistency
        deleteAllRelatedRecords();
        
        Test.startTest();
        
        // Create PM task
        Milestone1_Task__c task = createSamplePMTask('1');
        
        System.debug('PM Task Id = ' + task.Id);
        
        // Check Standard object Task
        Task sTask = [SELECT id, ownerId, activityDate
                      FROM Task
                      WHERE whatId = :task.Id][0];
        System.assertEquals(sTask.ownerId, task.assigned_to__c);
        System.assertEquals(sTask.activityDate, task.due_date__c);
        
        Test.stopTest();
    }
    
    /*
     *  Tests whether the associated Standard object task is also updated when
     *  PM Task is updated.
     */
    static testmethod void testPMTaskUpdate() {
        // For data consistency
        deleteAllRelatedRecords();
        
        Test.startTest();
        
        // Create PM task
        Milestone1_Task__c task = createSamplePMTask('1');
        
        task.due_date__c = Date.today() + 1;
        update task;
        
        
        Task sTask = [SELECT id, ownerId, activityDate
                      FROM Task
                      WHERE whatId = :task.Id][0];
        System.assertEquals(sTask.ownerId, task.assigned_to__c);
        System.assertEquals(sTask.activityDate, task.due_date__c);
        System.assertEquals(sTask.activityDate, Date.today() + 1);
        
        Test.stopTest();
    }
    
    /*
     *  Tests whether the associated Standard object task is also deleted when
     *  PM Task is deleted.
     */
    static testmethod void testPMTaskDelete() {
        // For data consistency
        deleteAllRelatedRecords();
        
        Test.startTest();
        
        // Create PM task
        Milestone1_Task__c task = createSamplePMTask('1');
        
        delete task;
        
        boolean isDeleted;
        try {
            Task sTask = [SELECT id, ownerId, activityDate
                          FROM Task
                          WHERE whatId = :task.Id][0];
            isDeleted = false;
        } catch(System.ListException e) {
            isDeleted = true;
        }
        
        System.assert(isDeleted);
        
        Test.stopTest();
    }
    
    /*
     *  Tests whether a PM Task is linked and updated after creating
     *  a Standard object Task.
     */
    static testmethod void testStandardTaskToPMTaskToLinking() {
        // For data consistency
        deleteAllRelatedRecords();
        
        Test.startTest();
        
        // Create PM task
        Milestone1_Task__c pmTask = createSamplePMTask('1');
        
        System.debug('PM Task Id = ' + pmTask.Id);
        
        // Create Standard Task
        Task task = createSampleStandardTask('1', pmTask.Id);
        
        // Check PM Task
        pmTask = [SELECT id, assigned_to__c, due_date__c
                  FROM Milestone1_Task__c
                  WHERE id = :pmTask.Id][0];
        System.assertEquals(pmTask.assigned_to__c, task.ownerId);
        System.assertEquals(pmTask.due_date__c, task.activityDate);
        
        Test.stopTest();
    }
    
    /*
     *  Tests whether the associated PM task is also updated when
     *  Standard Object Task is updated.
     */
    static testmethod void testStandardTaskUpdate() {
        // For data consistency
        deleteAllRelatedRecords();
        
        Test.startTest();
        
        // Create PM task
        Milestone1_Task__c pmTask = createSamplePMTask('1');
        
        System.debug('PM Task Id = ' + pmTask.Id);
        
        // Create Standard Task
        Task task = createSampleStandardTask('1', pmTask.Id);
        
        // Check PM Task
        pmTask = [SELECT id, assigned_to__c, due_date__c
                  FROM Milestone1_Task__c
                  WHERE id = :pmTask.Id][0];
        System.assertEquals(pmTask.assigned_to__c, task.ownerId);
        System.assertEquals(pmTask.due_date__c, task.activityDate);
        
        // Update standard object task
        task.activityDate = Date.today() + 7;
        update task;
        
        pmTask = [SELECT id, assigned_to__c, due_date__c
                  FROM Milestone1_Task__c
                  WHERE id = :pmTask.Id][0];
        System.assertEquals(pmTask.assigned_to__c, task.ownerId);
        System.assertEquals(pmTask.due_date__c, task.activityDate);
        
        Test.stopTest();
    }
    
    /*
     *  Tests whether the associated PM task is also deleted when
     *  Standard Object Task is deleted.
     */
    static testmethod void testStandardTaskDelete() {
        // For data consistency
        deleteAllRelatedRecords();
        
        Test.startTest();
        
        // Create PM task
        Milestone1_Task__c pmTask = createSamplePMTask('1');
        
        System.debug('PM Task Id = ' + pmTask.Id);
        
        // Create Standard Task
        Task task = createSampleStandardTask('1', pmTask.Id);
      
        delete pmTask;
        
        boolean isDeleted;
        try {
            Task sTask = [SELECT id, ownerId, activityDate
                          FROM Task
                          WHERE whatId = :pmTask.Id][0];
            isDeleted = false;
        } catch(System.ListException e) {
            isDeleted = true;
        }
        
        System.assert(isDeleted);
        
        Test.stopTest();
    }
    
    /*
     *  Tests that calls methods not called from previous tests.
     *  This is used to increase code coverage.
     */
    static testmethod void dummyTest() {
        // For data consistency
        deleteAllRelatedRecords();
        
        Test.startTest();
        
        // Test Milestone1_General_Utility
        String longName = 'abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz01234567890';
        Milestone1_General_Utility.processTaskName(longName);
        
        // Test Milestone1_Milestone_Trigger_Utility
        Map<Id, Milestone1_Milestone__c> mMap = new Map<Id, Milestone1_Milestone__c>();
        Milestone1_Milestone_Trigger_Utility.handleMilestoneDeleteTrigger(mMap);
        
        Milestone1_Milestone_Trigger_Utility.milestonePermissions('Milestone1_Milestone__c');
        Milestone1_Milestone_Trigger_Utility.milestonePermissions(null);
        
        Milestone1_Task__c pmTask = createSamplePMTask('1');
        Milestone1_Milestone__c milestone = [SELECT id, total_actual_hours__c, total_actual_expense__c,
                                                    total_estimated_hours__c, total_estimated_expense__c,
                                                    total_open_tasks__c, total_late_tasks__c, total_complete_tasks__c,
                                                    total_blocked_tasks__c, hours_budget__c, expense_budget__c, name
                                             FROM Milestone1_Milestone__c
                                             LIMIT 1];
        Milestone1_Milestone_Values_Helper helper = new  Milestone1_Milestone_Values_Helper(milestone);
        helper.addValuesFromChild(milestone);
        
        Test.stopTest();
    }
    
    //Utility method
    /*
     *  Utility method to create a task together with its prerequisite objects.
     *  Returns the newly created PM task.
     */
    private static Milestone1_Task__c createSamplePMTask(String recordNumber) {
        Milestone1_Project__c project = new Milestone1_Project__c(name = 'Sample Project #' + recordNumber);
        insert project;
        
        Milestone1_Milestone__c milestone = new Milestone1_Milestone__c(name = 'Sample Milestone #' + recordNumber,
                                                                        project__c = project.Id);
        insert milestone;
        
        Milestone1_Task__c task = new Milestone1_Task__c(name = 'Sample Task #' + recordNumber,
                                                         assigned_to__c = UserInfo.getUserId(),
                                                         project_milestone__c = milestone.Id,
                                                         priority__c = '0',
                                                         due_date__c = Date.today(),
                                                         task_stage__c = 'In Progress',
                                                         class__c = 'Ad hoc');
        insert task;
        
        return task;
    }
    
    /*
     *  Utility method to create a task together with its prerequisite objects.
     *  Returns the newly created standard object task.
     */
    private static Task createSampleStandardTask(String recordNumber, Id taskPMId) {
        Task task = new Task(ownerId = UserInfo.getUserId(),
                             activityDate = Date.today() + 1,
                             whatId = taskPMId);
        insert task;
        
        return task;
    }
    
    /*
     *  Deletes all records related to Task Syncing.
     *  This ensures data consistency during the tests.
     *
     *  All test methods must call this method first.
     */
    private static void deleteAllRelatedRecords() {
        //Delete all PM Task
        List<Milestone1_Task__c> pmTaskList = [SELECT id
                                               FROM Milestone1_Task__c];
        delete pmTaskList;
        
        // Delete all Standard object Task
        List<Task> taskList = [SELECT id
                               FROM Task];
        delete taskList;
    }

}