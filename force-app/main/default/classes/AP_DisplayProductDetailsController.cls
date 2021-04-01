/**************************************************************************
Apex Class Name    : AP_DisplayProductDetailsController
Version            : 1.0 
Created Date       : 01/04/2021
Function           : LWC controller class to display related Product2 details
					 on ProductHistory record page
----------------------------------------------------------------------------
* Developer             Date                   Description
* --------------------------------------------------------------------------                 
* Shubham Agrawal       01/04/2021             Original version
***************************************************************************/
public with sharing class AP_DisplayProductDetailsController {
    
    /************************************************************************************************
     * @Description - method to fetch related Product2 record Id based on ExternalId of 
     * ProductHistory record.
     * @Parameters - String productHistoryId
     * @Return Type - String - Product2 record Id
     */
    @AuraEnabled(cacheable=true)
    public static String getRelatedProductDetails(String productHistoryId){
        try {
            //get external id from the product history record
            String productExternalId = [SELECT ProductExternalId__c 
                                        FROM ProductHistory__c 
                                        WHERE Id = :productHistoryId
                                        WITH SECURITY_ENFORCED]?.ProductExternalId__c;
     
            if (String.isNotBlank(productExternalId)) {
                
                //get product2 id using product external id field value
                String product2Id = [SELECT Id 
                                     FROM Product2
                                     WHERE ProductExternalId__c = :productExternalId
                                     WITH SECURITY_ENFORCED]?.Id;
                if (String.isBlank(product2Id)) {
                    throw new AuraHandledException('No related product is available!');        
                } else {
                    return product2Id;
                }
            } else {
                throw new AuraHandledException('Incorrect Product External Id!');    
            }
        } catch (QueryException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}