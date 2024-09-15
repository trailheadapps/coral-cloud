import { LightningElement, api } from 'lwc';

export default class CoralCloudPageHeader extends LightningElement {
    @api title;
    @api subtitle;
    @api iconName;
}
