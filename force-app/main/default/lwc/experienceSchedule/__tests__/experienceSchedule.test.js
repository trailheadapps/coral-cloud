import { createElement } from 'lwc';
import ExperienceSchedule from 'c/experienceSchedule';
import getExperienceSessionsForDate from '@salesforce/apex/ExperienceController.getExperienceSessionsForDate';
import isCommunity from '@salesforce/apex/ContextService.isCommunity';

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
// Mock ContextService.isCommunity Apex wire adapter
jest.mock(
    '@salesforce/apex/ContextService.isCommunity',
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

/**
 * Creates the c-experience-schedule component and attach it to the page
 * @param {*} props component properties
 * @returns DOM element for the component
 */
function createTestComponent(props = {}) {
    const element = createElement('c-experience-schedule', {
        is: ExperienceSchedule
    });
    Object.assign(element, props);
    document.body.appendChild(element);
    return element;
}

describe('c-experience-schedule', () => {
    afterEach(() => {
        // Reset timers
        jest.useRealTimers();
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
        const element = createTestComponent({ recordId: 'fakeId' });

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

    it('renders when no experience is selected', async () => {
        const element = createTestComponent();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Check that date selection is hidden
        const dateEl = element.shadowRoot.querySelector(
            'lightning-formatted-date-time'
        );
        expect(dateEl).toBeNull();
        // Validate default message
        const messageEl = element.shadowRoot.querySelector(
            '.spinner-container p'
        );
        expect(messageEl.textContent).toContain('Select an experience');
    });

    it('renders when there are no sessions on the day', async () => {
        const element = createTestComponent({ recordId: 'fakeId' });

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

    it('renders open record button when not in XP Cloud site', async () => {
        const element = createTestComponent({ recordId: 'fakeId' });

        // Emit mock sessions and context on @wire
        getExperienceSessionsForDate.emit(mockSessions);
        isCommunity.emit(false);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Validate that open record button is displayed
        const buttonEls = element.shadowRoot.querySelectorAll(
            '.slds-box lightning-button-icon'
        );
        expect(buttonEls.length).toBe(mockSessions.length);
        expect(buttonEls[0].title).toBe(`Open record`);
    });

    it('renders book buttons when in XP Cloud site', async () => {
        // Set fake future time so that only one book button is displayed
        // the other book button is not displayed due to the session start time
        jest.useFakeTimers();
        jest.setSystemTime(new Date('2050-01-01T11:00:00'));

        // Create component
        const element = createTestComponent({ recordId: 'fakeId' });

        // Emit mock sessions and context on @wire
        getExperienceSessionsForDate.emit(mockSessions);
        isCommunity.emit(true);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Validate that only one book button is displayed
        const buttonEls = element.shadowRoot.querySelectorAll(
            '.slds-box lightning-button-icon'
        );
        expect(buttonEls.length).toBe(1);
        expect(buttonEls[0].title).toBe(`Book session`);
    });

    it('shows error panel element when error returned', async () => {
        const element = createTestComponent({ recordId: 'fakeId' });

        // Emit error from @wire
        getExperienceSessionsForDate.error();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Check for error panel
        const errorPanelEl = element.shadowRoot.querySelector('c-error-panel');
        expect(errorPanelEl).not.toBeNull();
    });

    it('is accessible when data is returned', async () => {
        const element = createTestComponent({ recordId: 'fakeId' });

        // Emit mock sessions on @wire
        getExperienceSessionsForDate.emit(mockSessions);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Check accessibility
        await expect(element).toBeAccessible();
    });
});
