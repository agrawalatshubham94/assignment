/**************************************************************************
Apex Class Name    : AP_TestDataFactory
Version            : 1.0 
Created Date       : 31/03/2021
Function           : Data factory class
----------------------------------------------------------------------------
* Developer             Date                   Description
* --------------------------------------------------------------------------                 
* Shubham Agrawal       31/03/2021             Original version
***************************************************************************/
public class AP_TestDataFactory {
    
    /************************************************************************************************
     * @Description - returns Product2 instance
     * @Parameters - String name, String code, Boolean isActive, String externalId, Decimal price
     * @Return Type - Product2 object instance
     */
	public static Product2 getProduct(String name, String code, Boolean isActive, String externalId, Decimal price) {
        return new Product2(
            Name = name,
            ProductCode = code,
            IsActive = isActive,
            ProductExternalId__c = externalId,
            SellingPrice__c = price
        );
    }
    
    /************************************************************************************************
     * @Description - returns ProductHistory__c instance
     * @Parameters - String name, Boolean isActive, String externalId, Decimal price
     * @Return Type - ProductHistory__c object instance
     */
    public static ProductHistory__c getProductHistory(String name, Boolean isActive, String externalId, Decimal price) {
        return new ProductHistory__c(
            Name = name,
            IsActive__c = isActive,
            ProductExternalId__c = externalId,
            SellingPrice__c = price
        );
    }
    
    /************************************************************************************************
     * @Description - returns User instance
     * @Parameters - String name, String profileName
     * @Return Type - User object instance
     */
    public static User getRunningUser(String name, String profileName) {
        
        if(String.isBlank(profileName) || String.isBlank(name)) return Null;
        
        String profileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1]?.Id;
        
        return new User(
            LastName = name,
            Email = name + '@testemail.com',
            Username = name + '@testemail.com.test',
            ProfileId = profileId,
            EmailEncodingKey = 'UTF-8',
            Alias = name.substring(1,3),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
    }
}