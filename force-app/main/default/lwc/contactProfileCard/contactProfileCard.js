import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import NAME_FIELD from '@salesforce/schema/Contact.Name';
import MAILING_CITY_FIELD from '@salesforce/schema/Contact.MailingCity';
import MAILING_STATE_FIELD from '@salesforce/schema/Contact.MailingState';
import PHOTO_URL_FIELD from '@salesforce/schema/Contact.Photo_URL__c';

const fields = [
    NAME_FIELD,
    MAILING_CITY_FIELD,
    MAILING_STATE_FIELD,
    PHOTO_URL_FIELD
];

export default class ContactProfileCard extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    contact;

    get hasData() {
        return this.contact?.data !== undefined;
    }

    get error() {
        return this.contact?.error;
    }

    get name() {
        return getFieldValue(this.contact.data, NAME_FIELD);
    }

    get mailingCity() {
        return getFieldValue(this.contact.data, MAILING_CITY_FIELD);
    }

    get mailingState() {
        return getFieldValue(this.contact.data, MAILING_STATE_FIELD);
    }

    get photoURL() {
        const photoURL = getFieldValue(this.contact.data, PHOTO_URL_FIELD);
        return photoURL
            ? photoURL
            : 'https://s3-us-west-2.amazonaws.com/dev-or-devrl-s3-bucket/sample-apps/coral-clouds/ntbg5p1mwixury672dxy.png';
    }
}
