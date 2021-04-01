@isTest
//Test class for AP_TestDataFactory data factory class
public class AP_TestDataFactoryTest {
    
	@isTest
    //testing Product2 instance insertion
    private static void getProductTest() {
        Test.startTest();
        Product2 productInstance = AP_TestDataFactory.getProduct('Product1', 'PR0001', true, '5812311ABD', 300.15);
        Database.insert(productInstance);
        Test.stopTest();
        
        Product2 insertedRec = [SELECT Id, Name, SellingPrice__c, IsActive FROM Product2];
        System.assertEquals(true, insertedRec.IsActive, 'Product2 is inserted and is active.');
    }
    
    @isTest
    //testing ProductHistory__c instance insertion
    private static void getProductHistoryTest() {
        Test.startTest();
        ProductHistory__c prodHistoryInstance = AP_TestDataFactory.getProductHistory('Product History 1', true, '5812311ABD', 300.15);
        Database.insert(prodHistoryInstance);
        Test.stopTest();
        
        ProductHistory__c insertedRec = [SELECT Id, Name, SellingPrice__c, IsActive__c FROM ProductHistory__c];
        System.assertEquals(true, insertedRec.IsActive__c, 'Product History is inserted and is active.');
    }
    
    @isTest
    //testing getRunningUser
    private static void getRunningUserTest() {
        Test.startTest();
        User userInstance = AP_TestDataFactory.getRunningUser('Test User', 'System Administrator');
        Test.stopTest();
        
        System.assertEquals('Test User', userInstance.LastName, 'last name mapped correctly');
        System.assertEquals([SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id, userInstance.ProfileId);
    }
}