import { createElement } from 'lwc';
import CoralCloudPageHeader from 'c/coralCloudPageHeader';

describe('c-coral-cloud-page-header', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders the header', () => {
        const element = createElement('c-coral-cloud-page-header', {
            is: CoralCloudPageHeader
        });
        element.title = 'test';
        element.subtitle = 'subtitle';
        document.body.appendChild(element);
        const header = element.shadowRoot.querySelector('.slds-page-header');
        expect(header).not.toBeNull();
    });
});
