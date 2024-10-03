import { createElement } from 'lwc';
import SessionBookingProgress from 'c/sessionBookingProgress';

const MOCK_BOOKED = 19;
const MOCK_CAPACITY = 25;
const MOCK_PERCENTAGE_BOOKED = 76;

describe('c-session-booking-progress', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders', async () => {
        const element = createElement('c-experience-booking-progress', {
            is: SessionBookingProgress
        });
        element.booked = MOCK_BOOKED;
        element.capacity = MOCK_CAPACITY;
        document.body.appendChild(element);

        // Validate displayed values agains mock data
        const labelEl = element.shadowRoot.querySelector('label');
        expect(labelEl.textContent).toBe(
            `Bookings: ${MOCK_BOOKED}/${MOCK_CAPACITY}`
        );
        const percentageEl = element.shadowRoot.querySelector('strong');
        expect(percentageEl.textContent).toBe(`${MOCK_PERCENTAGE_BOOKED}%`);
    });
});
