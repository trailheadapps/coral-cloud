import { LightningElement, api } from 'lwc';

export default class SessionBookingProgress extends LightningElement {
    @api booked;
    @api capacity;

    get label() {
        return `Bookings: ${this.booked}/${this.capacity}`;
    }

    get percentageBooked() {
        if (this.booked === undefined || this.capacity === undefined) {
            return '';
        }
        const bookedInt = parseInt(this.booked, 10);
        const capacityInt = parseInt(this.capacity, 10);
        return Math.round((bookedInt / capacityInt) * 100);
    }
}
