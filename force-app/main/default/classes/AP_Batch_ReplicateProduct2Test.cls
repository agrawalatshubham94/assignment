//Test class for AP_Batch_ReplicateProduct2 batch class
@isTest
public class AP_Batch_ReplicateProduct2Test {
    private static final User SYSTEM_ADMIN = AP_TestDataFactory.getRunningUser('Tester', 'System Administrator');
    
    //setting up test data to be used for testing batch class
	@testSetup
    private static void dataSetup() {
        List<Product2> products = new List<Product2>();
        for(Integer i=0; i<199; i++) {
            products.add(AP_TestDataFactory.getProduct('Product ' + i, 'PR00' + i, true, 'PR5831123' + i, 250.15));
        }        
        Database.insert(products);
    }
    
    //Sceario - Single batch execution should insert all the Product history records with respect to Product2 records
    @isTest
    private static void positiveScenarioTest() {
        System.runAs(SYSTEM_ADMIN) {
            
            //Batch will execute synchronously after Test.stopTest() 
            Test.startTest();
            AP_Batch_ReplicateProduct2 c = new AP_Batch_ReplicateProduct2(System.Label.Replicate_Product2_Records_Query);
            Database.executeBatch(c);
            Test.stopTest();
            
            Integer productHistoryCount = [SELECT Count() FROM ProductHistory__c];
            System.assertEquals(199, productHistoryCount, 'All Product History records created.');
        }
    }
    
    //Sceario - Product2 record without ExternalId field will cause error and hence record count will remain 199
    @isTest
    private static void neagtiveScenarioTest() {
        Database.insert(AP_TestDataFactory.getProduct('Product without ExternalId', 'PR00FAIL', true, Null, 250.15));
        
        System.runAs(SYSTEM_ADMIN) {
            
            //Batch will execute synchronously after Test.stopTest() 
            Test.startTest();
            AP_Batch_ReplicateProduct2 c = new AP_Batch_ReplicateProduct2(System.Label.Replicate_Product2_Records_Query);
            Database.executeBatch(c);
            Test.stopTest();
            
            Integer productHistoryCount = [SELECT Count() FROM ProductHistory__c];
            System.assertEquals(199, productHistoryCount, 'Product history records remained 199');
        }
    }
}