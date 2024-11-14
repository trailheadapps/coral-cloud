import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import BOOKED_SLOT_FIELD from '@salesforce/schema/Session__c.Booked_Slots__c';
import CAPACITY_FIELD from '@salesforce/schema/Session__c.Capacity__c';

const fields = [BOOKED_SLOT_FIELD, CAPACITY_FIELD];

export default class SessionBookingOverview extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    session;

    get booked() {
        return getFieldValue(this.session.data, BOOKED_SLOT_FIELD);
    }

    get capacity() {
        return getFieldValue(this.session.data, CAPACITY_FIELD);
    }
}
