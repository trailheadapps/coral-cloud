import { createElement } from 'lwc';
import ExperienceSchedule from 'c/experienceSchedule';
import getExperienceSessionsForDate from '@salesforce/apex/ExperienceController.getExperienceSessionsForDate';

// Realistic list of mock sessions
const mockSessions = require('./data/getExperienceSessionsForDate.json');

// Mock getExperienceSessionsForDate Apex wire adapter
jest.mock(
    '@salesforce/apex/ExperienceController.getExperienceSessionsForDate',
    () => {
        const {
            createApexTestWireAdapter
        } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

describe('c-experience-schedule', () => {
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

    it('renders when there are sessions on the day', async () => {
        const element = createElement('c-experience-schedule', {
            is: ExperienceSchedule
        });
        document.body.appendChild(element);

        // Emit mock sessions on @wire
        getExperienceSessionsForDate.emit(mockSessions);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Validate displayed values agains mock data
        const cardEls = element.shadowRoot.querySelectorAll('.slds-box');
        expect(cardEls.length).toBe(mockSessions.length);

        const labelEls = cardEls[0].querySelectorAll(
            '.slds-form-element div.slds-form-element__control'
        );
        const statusEl = labelEls[labelEls.length - 2];
        expect(statusEl.textContent).toBe(`${mockSessions[0].Status__c}`);
    });

    it('renders when there are no sessions on the day', async () => {
        const element = createElement('c-experience-schedule', {
            is: ExperienceSchedule
        });
        document.body.appendChild(element);

        // Emit no sessions on @wire
        getExperienceSessionsForDate.emit([]);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Validate displayed values agains mock data
        const messageEl = element.shadowRoot.querySelector(
            '.spinner-container p'
        );
        expect(messageEl.textContent).toContain('No sessions');
    });

    it('shows error panel element when error returned', async () => {
        // Create component
        const element = createElement('c-experience-schedule', {
            is: ExperienceSchedule
        });
        document.body.appendChild(element);

        // Emit error from @wire
        getExperienceSessionsForDate.error();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Check for error panel
        const errorPanelEl = element.shadowRoot.querySelector('c-error-panel');
        expect(errorPanelEl).not.toBeNull();
    });

    it('is accessible when data is returned', async () => {
        // Create component
        const element = createElement('c-experience-schedule', {
            is: ExperienceSchedule
        });
        document.body.appendChild(element);

        // Emit mock sessions on @wire
        getExperienceSessionsForDate.emit(mockSessions);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Check accessibility
        await expect(element).toBeAccessible();
    });
});
