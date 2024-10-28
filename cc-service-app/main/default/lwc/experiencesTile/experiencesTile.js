import { LightningElement, api } from 'lwc';

/**
 * A presentation component to display a Experience__c sObject. The provided
 * Experience__c data must contain all fields used by this component.
 */
export default class ExperiencesTile extends LightningElement {
    _experience;

    /** Experience__c to display. */
    @api
    get experience() {
        return this._experience;
    }
    set experience(value) {
        this._experience = value;
        this.pictureUrl = value.Picture_URL__c;
        this.name = value.Name;
        this.description = value.Description__c;
        this.rating = value.Rating__c;
    }

    /** Experience__c field values to display. */
    pictureUrl;
    name;
    description;
    rating;

    handleClick() {
        const selectedEvent = new CustomEvent('selected', {
            detail: this.experience.Id
        });
        this.dispatchEvent(selectedEvent);
        this.template.querySelector('a').style.color = 'rgb(238, 137, 111)';
    }
}
