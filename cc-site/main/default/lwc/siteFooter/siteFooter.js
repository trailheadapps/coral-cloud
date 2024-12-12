import { LightningElement } from 'lwc';
import IMAGE_URL from '@salesforce/resourceUrl/coralcloudsite';

export default class SiteFooter extends LightningElement {
    get logoUrl() {
        return `${IMAGE_URL}/coral-cloud-logo.png`;
    }
}
