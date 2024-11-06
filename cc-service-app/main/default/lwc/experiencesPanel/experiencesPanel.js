import { LightningElement, wire, track } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import EXPERIENCE_TYPE_FIELD from '@salesforce/schema/Experience__c.Type__c';
import EXPERIENCE_SELECTED_MESSAGE from '@salesforce/messageChannel/ExperienceSelected__c';
import getExperiences from '@salesforce/apex/ExperienceController.getExperiences';

export default class ExperiencePanel extends LightningElement {
    types = [];
    type;
    pageSize;
    totalItemCount;
    pageNumber = 1;
    error;

    @track experiences;

    @wire(MessageContext) messageContext;

    @wire(getExperiences, { type: '$type', pageNumber: '$pageNumber' })
    wiredExperiences({ error, data }) {
        if (data) {
            this.pageSize = data.pageSize;
            this.totalItemCount = data.totalItemCount;
            this.experiences = data.records.map((experienceRecord) => {
                const experience = { ...experienceRecord };
                experience.isSelected = false;
                return experience;
            });
        } else if (error) {
            this.experiences = undefined;
            this.error = error;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA', // Default record type Id
        fieldApiName: EXPERIENCE_TYPE_FIELD
    })
    getExperienceTypePicklistValues({ error, data }) {
        if (data) {
            this.types = data.values;
            if (data.values.length > 0) {
                this.type = data.values[0].value;
            }
        } else if (error) {
            this.error = error;
        }
    }

    handleExperienceSelected(event) {
        const experienceId = event.detail;
        // Update selection
        this.experiences.forEach((experience) => {
            experience.isSelected = experience.Id === experienceId;
        });
        // Send Lightning message to notify selection
        publish(this.messageContext, EXPERIENCE_SELECTED_MESSAGE, {
            experienceId
        });
    }

    handleTypeChange(event) {
        this.type = event.target.value;
        this.pageNumber = 1;
    }

    handleFilterChange(message) {
        this.filters = { ...message.filters };
        this.pageNumber = 1;
    }

    handlePreviousPage() {
        this.pageNumber = this.pageNumber - 1;
    }

    handleNextPage() {
        this.pageNumber = this.pageNumber + 1;
    }

    get hasNoExperiences() {
        return this.experiences && this.experiences.length === 0;
    }
}
