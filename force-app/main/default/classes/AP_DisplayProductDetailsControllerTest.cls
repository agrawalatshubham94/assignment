//Test class for AP_DisplayProductDetailsController LWC controller class
@isTest
private class AP_DisplayProductDetailsControllerTest {
    
    //external id to create Product2 and related ProductHistory__c records
    private static final String EXTERNALID = 'PR5816002';
    
    //Dummy admin user to run in System Admin context
    private static final User SYSTEM_ADMIN = AP_TestDataFactory.getRunningUser('Tester', 'System Administrator');
    
    @testSetup
    //setting up test data
    private static void dataSetup() {
        
        //creating products
        List<Product2> products = new List<Product2>();        
        products.add(AP_TestDataFactory.getProduct('Product Without External Id', 'APPR00', true, Null, 250.15));
        products.add(AP_TestDataFactory.getProduct('Product With External Id', 'APPR01', true, EXTERNALID, 350.15));
        Database.insert(products);
        
        //creating related product history records
        List<ProductHistory__c> productHistories = new List<ProductHistory__c>();
        productHistories.add(AP_TestDataFactory.getProductHistory('Product With External Id', true, EXTERNALID, 350.15));
        productHistories.add(AP_TestDataFactory.getProductHistory('Product Without External Id', true, Null, 350.15));
        productHistories.add(AP_TestDataFactory.getProductHistory('Product History Without Product', true, 'PR5816010', 350.15));
        Database.insert(productHistories);
    }
    
    @isTest
    //Scenario - fetch related product2 id correctly by passing producthistory record id
    private static void getRelatedProductDetailsTest1() {
        System.runAs(SYSTEM_ADMIN) {
            String productHistoryId = [SELECT Id FROM ProductHistory__c WHERE Name = 'Product With External Id' LIMIT 1]?.Id;
            Test.startTest();
            String product2Id = AP_DisplayProductDetailsController.getRelatedProductDetails(productHistoryId);
            Test.stopTest(); 
            System.assertNotEquals(Null, product2Id);
        }
    }
    
    @isTest
    //Scenario - negative scenario, exception should be thrown in case of history record having blank/null external id
    private static void getRelatedProductDetailsTest2() {
        String productId;
            
        System.runAs(SYSTEM_ADMIN) {
            String productHistoryId = [SELECT Id FROM ProductHistory__c WHERE Name = 'Product Without External Id' LIMIT 1]?.Id;
            Test.startTest();
            try {
                productId = AP_DisplayProductDetailsController.getRelatedProductDetails(productHistoryId);
            } catch (AuraHandledException e) {
                System.assertEquals(e.getTypeName(), 'System.AuraHandledException');
                System.assertEquals(Null , productId);
            }            
            Test.stopTest(); 
        }
    }
    
    @isTest
    //Scenario - negative scenario, exception should be thrown in case no matching product2 found
    private static void getRelatedProductDetailsTest3() {
        String productId;
            
        System.runAs(SYSTEM_ADMIN) {
            String productHistoryId = [SELECT Id FROM ProductHistory__c WHERE Name = 'Product History Without Product' LIMIT 1]?.Id;
            Test.startTest();
            try {
                productId = AP_DisplayProductDetailsController.getRelatedProductDetails(productHistoryId);
            } catch (AuraHandledException e) {
                System.assertEquals(e.getTypeName(), 'System.AuraHandledException');
                System.assertEquals(Null , productId);
            }            
            Test.stopTest(); 
        }
    }
}