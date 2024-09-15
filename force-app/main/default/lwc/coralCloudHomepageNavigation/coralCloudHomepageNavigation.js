import { LightningElement, api } from 'lwc';

export default class CoralCloudHomePageNavigation extends LightningElement {
    @api navigationItems;
    @api selectedItem;

    selectItem(event) {
        const name = event.currentTarget.name;
        const selectedEvent = new CustomEvent('navselect', { detail: name });
        this.dispatchEvent(selectedEvent);
    }
}
