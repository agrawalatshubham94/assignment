/**************************************************************************
Apex Class Name    : AP_Scheduler_ReplicateProduct2
Version            : 1.0 
Created Date       : 01/04/2021
Function           : Scheduler for Replicate Product2 batch class
----------------------------------------------------------------------------
* Developer             Date                   Description
* --------------------------------------------------------------------------                 
* Shubham Agrawal       01/04/2021             Original version
***************************************************************************/
public class AP_Scheduler_ReplicateProduct2 implements Schedulable {
    
    //fetch all the configurations related to replicate product2 process execution from metadata object
    public static Map<String, String> config = new Map<String, String>();    
    static {
        for(ReplicateProduct2Config__mdt meta : [SELECT Value__c, MasterLabel FROM ReplicateProduct2Config__mdt]) {
            config.put(meta.MasterLabel, meta.Value__c);
        }
    }
    
    /* ***********************************************************************************************
     * @Description - execute method implemented of scheduler interface
     * @Parameters - SchedulableContext SC
     * @Return Type - void
     */
    public void execute(SchedulableContext SC) { 
        
        //check if execution of batch is enabled using config meta
        if(Boolean.valueOf(config.get('IsEnabled'))) {
            
            //execute replicate product2 batch class
            AP_Batch_ReplicateProduct2 batch = new AP_Batch_ReplicateProduct2(String.valueOf(config.get('BatchQuery')));
        	Database.executeBatch(batch, 500);
        	
        }        
    }

    /* ***********************************************************************************************
     * @Description - method to schedule the apex and return job id. Additional feature to abort previous jobs along 
     * with scheduling the new ones.
     * @Parameters - SchedulableContext SC
     * @Return Type - String JobId
     */
    public static String schedule(String cronString, Boolean abortPreviousJobs) {
        
        if(abortPreviousJobs) unschedule(); //conditionally abort previous jobs
        
        //schedule apex at a give time passed as a cron string
        if(String.isNotBlank(cronString)) {
            return System.Schedule(config.get('BatchJobName'), cronString, new AP_Scheduler_ReplicateProduct2());
        }
        return Null;
    }
    
    /* ***********************************************************************************************
     * @Description - method to abort replicate product2 scheduled apex instances
     * @Parameters - SchedulableContext SC
     * @Return Type - String JobId
     */
    public static void unschedule() {
        for (CronTrigger ct : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :(config.get('BatchJobName') + '%')]) {
            System.AbortJob(ct.Id);
        }
    }
}