import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {
    MessageContext,
    subscribe,
    unsubscribe
} from 'lightning/messageService';
import EXPERIENCE_SELECTED_CHANNEL from '@salesforce/messageChannel/ExperienceSelected__c';
import NAME_FIELD from '@salesforce/schema/Experience__c.Name';
import TYPE_FIELD from '@salesforce/schema/Experience__c.Type__c';
import DURATION_FIELD from '@salesforce/schema/Experience__c.Duration_Hours__c';
import PRICE_FIELD from '@salesforce/schema/Experience__c.Price__c';
import ACTIVITY_LEVEL_FIELD from '@salesforce/schema/Experience__c.Activity_Level__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Experience__c.Description__c';

const FIELDS = [
    NAME_FIELD,
    TYPE_FIELD,
    DURATION_FIELD,
    PRICE_FIELD,
    ACTIVITY_LEVEL_FIELD,
    DESCRIPTION_FIELD
];

export default class ExperienceDetails extends NavigationMixin(
    LightningElement
) {
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

    get fields() {
        return FIELDS;
    }

    get isNoExperienceSelected() {
        return !this._recordId;
    }

    handleViewExperienceClick() {
        if (!this._recordId) {
            return;
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this._recordId,
                objectApiName: 'Experience__c',
                actionName: 'view'
            }
        });
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
