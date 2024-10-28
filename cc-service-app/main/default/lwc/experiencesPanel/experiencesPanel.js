import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import EXPERIENCE_SELECTED_MESSAGE from '@salesforce/messageChannel/ExperienceSelected__c';
import getExperiences from '@salesforce/apex/ExperienceController.getExperiences';

export default class ExperiencePanel extends LightningElement {
    pageNumber = 1;
    pageSize;
    totalItemCount = 0;
    types = [
        { label: 'Adventure Activities', value: 'Adventure Activities' },
        { label: 'Beaches & Snorkeling', value: 'Beaches & Snorkeling' },
        {
            label: 'Cultural Tours & Workshops',
            value: 'Cultural Tours & Workshops'
        },
        { label: 'Dining Experiences', value: 'Dining Experiences' },
        {
            label: "Family & Kids' Activities",
            value: "Family & Kids' Activities"
        },
        { label: 'Fitness & Exercise', value: 'Fitness & Exercise' },
        { label: 'Golf', value: 'Golf' },
        { label: 'Nature & Eco Tours', value: 'Nature & Eco Tours' },
        {
            label: 'Nightlife & Entertainment',
            value: 'Nightlife & Entertainment'
        },
        {
            label: 'Relaxation & Quiet Zones',
            value: 'Relaxation & Quiet Zones'
        },
        { label: 'Spa & Wellness', value: 'Spa & Wellness' },
        { label: 'Swimming Pools', value: 'Swimming Pools' },
        { label: 'Tennis & Pickleball', value: 'Tennis & Pickleball' },
        { label: 'Water Sports', value: 'Water Sports' }
    ];
    type = 'Adventure Activities';
    recordTypeId;
    @wire(MessageContext) messageContext;

    @wire(getExperiences, { type: '$type', pageNumber: '$pageNumber' })
    experiences;

    handleExperienceSelected(event) {
        publish(this.messageContext, EXPERIENCE_SELECTED_MESSAGE, {
            experienceId: event.detail
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
}
