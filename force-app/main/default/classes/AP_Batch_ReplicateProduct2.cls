/**************************************************************************
Apex Class Name    : AP_Batch_ReplicateProduct2
Version            : 1.0 
Created Date       : 31/03/2021
Function           : Batch class to Replicate Product2 records in custom 
					 object ProductHistory__c
----------------------------------------------------------------------------
* Developer             Date                   Description
* --------------------------------------------------------------------------                 
* Shubham Agrawal       31/03/2021             Original version
***************************************************************************/
public with sharing class AP_Batch_ReplicateProduct2 implements Database.Batchable<sObject>, Database.Stateful {
    
	//SOQL query string to set the scope of batch class
    public final String query;
    
    //External Id field to upsert the related Product History records
    public static final Schema.SObjectField externalIdField = ProductHistory__c.Fields.ProductExternalId__c;
	
    //Map to hold failures incountered while upsert. To be sent as CSV file for reference.
    public Map<Product2, String> failedRecords = new Map<Product2, String>();
    
    //email address to which failure records to be sent
    public static final String failureEmail = 'shubham.c.agrawal@gmail.com';
    
    //constructor call
    public AP_Batch_ReplicateProduct2(String query){        
        this.query = query;
    }
    
    /************************************************************************************************
     * @Description - start method of Batchable interface to set the scope of the batch
     * @Parameters - Database.BatchableContext BC
     * @Return Type - Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    /************************************************************************************************
     * @Description - execute method of Batchable interface to process the scope
     * @Parameters - Database.BatchableContext BC, List<Product2> scope
     * @Return Type - void
     */
    public void execute(Database.BatchableContext BC, List<Product2> scope){
        List<ProductHistory__c> productHistoryList = new List<ProductHistory__c>();

        /*NOTE: Not handling the delete scenario as Product2 records will be marked Inactive if they
                are no longer needed. Deactivated Product2 records will also be synced with related
                ProductHistory__c records by using another custom field ProductHistory__c.IsActive__c.
        */    

        //iterate through the Product2 records and add a related instance of ProductHistory
        //in the list
        for(Product2 product : scope){
            productHistoryList.add(new ProductHistory__c(
                Name = product.Name,
                SellingPrice__c = product.SellingPrice__c,
                ProductExternalId__c = product.ProductExternalId__c,
                IsActive__c = product.IsActive
            ));	    
        }
        
        //upsert the productHistoryList using external Id and allOrNone flag set to false
        //this is an optional step but best practice to handle failure scenario.
        List<Database.UpsertResult> resultList = Database.upsert(productHistoryList, externalIdField, false);
        for(Integer i=0; i<resultList.size(); i++) {
            if(!resultList[i].isSuccess()) {
                String errors;  //concatenated errors list
                for(Database.Error err : resultList[i].getErrors()) {
                    errors += err.getMessage() + ';';  //concatenate errors
                }
                failedRecords.put(scope[i], errors);
            }
        }
    }
    
    /************************************************************************************************
     * @Description - finish method of Batchable interface to execute steps to be performed once at 
     * the end of batch completion
     * @Parameters - Database.BatchableContext BC
     * @Return Type - void
     */
    public void finish(Database.BatchableContext BC){
        //if there are any failures then send and email with failure records as attachment
        if(!failedRecords.isEmpty()) sendRecordFailureEmail(BC.getJobId());
    }
    
    /************************************************************************************************
     * @Description - Send email with failure records as CSV file attachment
     * @Parameters - String JobId
     * @Return Type - void
     */
    private void sendRecordFailureEmail(String jobId) { 
        
        /*NOTE: This is just to demonstrate that how we can handle errors by sending an automated
                email containing the failure records and reason why they failed.
                One edge case here could be that in case we are having thousands of failures than
                using String concatenation could result in failure. But this can also be overcome by 
                splitting it to multiple attachments.        
        */

        //prepare csv file content interating through failure records
        String finalString = 'Product Id,Product Name, Selling Price, Product ExternalId,Errors\n';
        for(Product2 rec : failedRecords.keySet()) {
            finalString+= rec.Id + ',' + rec.Name + ',' + rec.SellingPrice__c + ',' + rec.ProductExternalId__c + ',' + failedRecords.get(rec) + '\n';            
        }
        
        //set email attachment
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvBlob = Blob.valueOf(finalString);
        csvAttc.setFileName('ReplicateProduct2Failures.csv');
        csvAttc.setBody(csvBlob);
        
        //set email configurations
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        email.setSubject('Replicate Product2 Job Id-' + jobId + ' Completed');
        email.setToAddresses( new List<string>{failureEmail} );
        email.setPlainTextBody('Please find attached CSV file containing failure records.');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}