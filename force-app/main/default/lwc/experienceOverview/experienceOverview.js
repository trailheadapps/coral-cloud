import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Experience__c.Name';
import DESCRIPTION_FIELD from '@salesforce/schema/Experience__c.Description__c';
import PICTURE_FIELD from '@salesforce/schema/Experience__c.Picture_URL__c';

const fields = [NAME_FIELD, DESCRIPTION_FIELD, PICTURE_FIELD];

export default class ExperienceOverview extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    experience;

    get name() {
        return getFieldValue(this.experience.data, NAME_FIELD);
    }

    get description() {
        return getFieldValue(this.experience.data, DESCRIPTION_FIELD);
    }

    get pictureURL() {
        return getFieldValue(this.experience.data, PICTURE_FIELD);
    }
}
