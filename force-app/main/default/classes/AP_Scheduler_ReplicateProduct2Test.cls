//Test class for AP_Scheduler_ReplicateProduct2 scheduler class
@isTest
public class AP_Scheduler_ReplicateProduct2Test {
	private static final User SYSTEM_ADMIN = AP_TestDataFactory.getRunningUser('Tester', 'System Administrator');
    
    @isTest
    //test method to trigger scheduler apex class
    private static void schedulableTest() {
        System.runAs(SYSTEM_ADMIN) {
            
            //scheduling apex inside Test.startTest() and Test.stopTest() methods to execute immediately after
            //Test.stopTest() execution
            Test.startTest();
            String jobId = AP_Scheduler_ReplicateProduct2.schedule('0 0 0 3 9 ? 2022', true);
            System.assertEquals(String.isNotBlank(jobId), true);
            
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, TimesTriggered, State
                              FROM CronTrigger 
                              WHERE Id = :jobId];
            System.assertEquals(0, ct.TimesTriggered);
            Test.stopTest();
        }
    }
}