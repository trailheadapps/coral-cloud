import { createElement } from 'lwc';
import ExperienceOverview from 'c/experienceOverview';
import { getRecord } from 'lightning/uiRecordApi';

const mockGetRecord = require('./data/getRecord.json');

describe('c-experience-overview', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    // Helper function to wait until the microtask queue is empty. This is needed for promise
    // timing when calling imperative Apex.
    async function flushPromises() {
        return Promise.resolve();
    }

    it('renders the experience overview', async () => {
        const element = createElement('c-experience-overview', {
            is: ExperienceOverview
        });
        document.body.appendChild(element);

        // Emit data from @wire
        getRecord.emit(mockGetRecord);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Validate displayed values agains mock data
        const imgEl = element.shadowRoot.querySelector('.experience-image');
        expect(imgEl.src).toBe(mockGetRecord.fields.Picture_URL__c.value);
        const nameEl = element.shadowRoot.querySelector('h2');
        expect(nameEl.textContent).toBe(mockGetRecord.fields.Name.value);
    });

    it('is accessible when data is returned', async () => {
        // Create component
        const element = createElement('c-experience-overview', {
            is: ExperienceOverview
        });
        document.body.appendChild(element);

        // Emit data from @wire
        getRecord.emit(mockGetRecord);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Check accessibility
        await expect(element).toBeAccessible();
    });
});
