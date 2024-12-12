import { LightningElement, api } from 'lwc';

/**
 * A presentation component to display a Experience__c sObject. The provided
 * Experience__c data must contain all fields used by this component.
 */
export default class ExperiencesTile extends LightningElement {
    /** Experience__c to display. */
    @api experience;

    handleClick() {
        const selectedEvent = new CustomEvent('selected', {
            detail: this.experience.Id
        });
        this.dispatchEvent(selectedEvent);
    }

    get tileClasses() {
        return this.experience.isSelected ? 'selected' : '';
    }
}
