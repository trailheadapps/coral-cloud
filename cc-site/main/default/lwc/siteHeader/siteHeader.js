import { LightningElement } from 'lwc';
import LightningAlert from 'lightning/alert';

export default class SiteHeader extends LightningElement {
    async handleBookClick() {
        await LightningAlert.open({
            message: `This feature isn't implemented, check again later.`,
            theme: 'warn',
            label: 'Not Implemented'
        });
    }
}
