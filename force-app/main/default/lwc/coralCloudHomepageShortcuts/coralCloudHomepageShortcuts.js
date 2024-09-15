import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import workshopDetails from '@salesforce/resourceUrl/workshopDetails';
import { loadScript } from 'lightning/platformResourceLoader';

const navigationItemsWithoutChapters = [{ label: 'Home', value: 'home' }];

export default class CoralCloudHomepageShortcuts extends NavigationMixin(
    LightningElement
) {
    navigationItems = navigationItemsWithoutChapters;

    selectedItem = 'home';
    libInitialized = false;
    workshopData = [];
    selectedWorkshop;

    async renderedCallback() {
        if (this.libInitialized) {
            return;
        }
        this.libInitialized = true;
        try {
            await loadScript(this, workshopDetails);
            // eslint-disable-next-line no-undef
            this.workshopData = workshopData.getData();
        } catch (e) {
            throw new Error('Failed to load workshop data: ' + e, e);
        }
    }

    handleNavSelect(event) {
        const name = event.detail;
        this.selectedItem = name;
        if (name !== 'home') {
            this.selectedWorkshop = this.workshopData.find(
                (workshop) => workshop.name === this.selectedItem
            );
        }
    }

    view(event) {
        const viewType = event.currentTarget.dataset.type;
        let url;
        if (viewType === 'url') {
            url = event.currentTarget.dataset.url;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url
            }
        });
    }

    get showHome() {
        return this.selectedItem === 'home';
    }
}
