import { LightningElement, api, wire } from 'lwc';
import {
    MessageContext,
    subscribe,
    unsubscribe
} from 'lightning/messageService';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Experience__c.Name';
import DESCRIPTION_FIELD from '@salesforce/schema/Experience__c.Description__c';
import PICTURE_FIELD from '@salesforce/schema/Experience__c.Picture_URL__c';
import EXPERIENCE_SELECTED_CHANNEL from '@salesforce/messageChannel/ExperienceSelected__c';

const fields = [NAME_FIELD, DESCRIPTION_FIELD, PICTURE_FIELD];

export default class ExperienceOverview extends LightningElement {
    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
    }

    _recordId;
    subscription;

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: '$_recordId', fields })
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

    get isNoExperienceSelected() {
        return !this._recordId;
    }

    connectedCallback() {
        this.subscribeToExperienceSelectedChannel();
    }

    disconnectedCallback() {
        this.unsubscribeFromExperienceSelectedChannel();
    }

    subscribeToExperienceSelectedChannel() {
        if (this.subscription) {
            return;
        }

        this.subscription = subscribe(
            this.messageContext,
            EXPERIENCE_SELECTED_CHANNEL,
            (message) => {
                this._recordId = message.experienceId;
            }
        );
    }

    unsubscribeFromExperienceSelectedChannel() {
        if (!this.subscription) {
            return;
        }

        unsubscribe(this.subscription);
        this.subscription = null;
    }
}
