//import required modules from 'lwc'
import { LightningElement, wire, api, track } from 'lwc';
//importing apex method to fetch related Product2 Id
import getRelatedProduct from '@salesforce/apex/AP_DisplayProductDetailsController.getRelatedProductDetails';

export default class Lwc_DisplayProductDetails extends LightningElement {
    @api recordId; //to hold current record id
    @track error;  //to hold error message 
    @track product2Id;  //to hold Product2 id retrun via Apex method

    @wire(getRelatedProduct, { productHistoryId : '$recordId' })
    product({ error, data }) {
        //handle error occurred while executing apex call
        if(error) {
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
        } else if (data) {
            this.product2Id = data;
        }
    };
}