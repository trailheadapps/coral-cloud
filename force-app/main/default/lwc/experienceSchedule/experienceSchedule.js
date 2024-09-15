import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getExperienceSessionsForDate from '@salesforce/apex/ExperienceController.getExperienceSessionsForDate';

export default class ExperienceSchedule extends NavigationMixin(
    LightningElement
) {
    @api recordId;

    sessions = [];
    error;
    loading = true;
    date = new Date();

    @wire(getExperienceSessionsForDate, {
        experienceId: '$recordId',
        timestamp: '$timestamp'
    })
    wiredSessions({ error, data }) {
        this.loading = false;
        if (error) {
            this.error = error;
            this.sessions = undefined;
        } else if (data) {
            this.error = undefined;
            this.sessions = data.map((sessionRecord) => {
                // Clone record to add extra fields and avoid proxy issues
                const session = { ...sessionRecord };
                // Generate unique labels for accessibility
                session.labelStartTime = `start${session.Id}`;
                session.labelEndTime = `end${session.Id}`;
                session.labelStatus = `status${session.Id}`;
                session.labelBookings = `bookings${session.Id}`;
                return session;
            });
        } else {
            this.sessions = [];
        }
    }

    handleNextDayClick() {
        const newDate = new Date(this.date);
        newDate.setDate(newDate.getDate() + 1);
        this.date = newDate;
        this.loading = true;
    }

    handlePreviousDayClick() {
        const newDate = new Date(this.date);
        newDate.setDate(newDate.getDate() - 1);
        this.date = newDate;
        this.loading = true;
    }

    handleViewSessionClick(event) {
        const sessionId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: sessionId,
                actionName: 'view'
            }
        });
    }

    get timestamp() {
        return this.date.getTime();
    }

    get isNoSessionAvailable() {
        return this.sessions?.length === 0;
    }

    get sessionCountLabel() {
        const count = this.sessions.length;
        if (count === 1) {
            return 'A session is scheduled on this day:';
        }
        return `${count} sessions are scheduled on this day:`;
    }
}
