import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CoralCloudHomepageShortcut extends NavigationMixin(
    LightningElement
) {
    @api name;
    @api label;
    @api iconName;
    @api link;

    view(event) {
        let url = event.currentTarget.dataset.url;
        window.open(url);
        /*
        this[NavigationMixin.Navigate]({
          type: "standard__webPage",
          attributes: {
            url
          }
        });
        */
    }
}
