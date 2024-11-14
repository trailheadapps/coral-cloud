import { createElement } from 'lwc';
import SessionBookingOverview from 'c/sessionBookingOverview';
import { getRecord } from 'lightning/uiRecordApi';

const mockGetRecord = require('./data/getRecord.json');

describe('c-session-booking-overview', () => {
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

    it('renders the session booking overview', async () => {
        const element = createElement('c-session-booking-overview', {
            is: SessionBookingOverview
        });
        document.body.appendChild(element);

        // Emit data from @wire
        getRecord.emit(mockGetRecord);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Validate that booking progress is displayed
        const progressEl = element.shadowRoot.querySelector(
            'c-session-booking-progress'
        );
        expect(progressEl).not.toBeNull();
    });

    it('is accessible when data is returned', async () => {
        // Create component
        const element = createElement('c-session-booking-overview', {
            is: SessionBookingOverview
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
