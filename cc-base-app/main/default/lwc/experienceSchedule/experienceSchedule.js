import { LightningElement, api, wire } from 'lwc';
import LightningAlert from 'lightning/alert';
import { NavigationMixin } from 'lightning/navigation';
import getExperienceSessionsForDate from '@salesforce/apex/ExperienceController.getExperienceSessionsForDate';
import isCommunity from '@salesforce/apex/ContextService.isCommunity';

const ONE_HOUR_IN_MS = 3600000;
const ONE_MINUTE_IN_MS = 60000;

export default class ExperienceSchedule extends NavigationMixin(
    LightningElement
) {
    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
    }

    _recordId;
    sessions = [];
    error;
    loading = true;
    date = new Date();
    isCommunity;

    @wire(isCommunity)
    wiredCommunityInfo({ error, data }) {
        if (error) {
            this.error = error;
            this.isCommunity = undefined;
        } else if (data) {
            this.isCommunity = data;
            this.error = undefined;
        }
    }

    @wire(getExperienceSessionsForDate, {
        experienceId: '$_recordId',
        timestamp: '$timestamp'
    })
    wiredSessions({ error, data }) {
        this.loading = false;
        if (error) {
            this.error = error;
            this.sessions = undefined;
        } else if (data) {
            this.error = undefined;
            const now = new Date().getTime();
            this.sessions = data.map((sessionRecord) => {
                // Clone record to add extra fields and avoid proxy issues
                const session = { ...sessionRecord };
                // Add future start check
                const start = new Date(this.date);
                const hours = Math.floor(
                    session.Start_Time__c / ONE_HOUR_IN_MS
                );
                const minutes = Math.floor(
                    (session.Start_Time__c - hours * ONE_HOUR_IN_MS) /
                        ONE_MINUTE_IN_MS
                );
                start.setHours(hours);
                start.setMinutes(minutes);
                start.setSeconds(0);
                session.isFutureStart = start.getTime() > now;
                // Generate unique labels for accessibility
                session.labelStartTime = `start${session.Id}`;
                session.labelEndTime = `end${session.Id}`;
                session.labelStatus = `status${session.Id}`;
                session.labelBookings = `bookings${session.Id}`;
                session.labelPrice = `price${session.Id}`;
                return session;
            });
        } else {
            this.sessions = [];
        }
    }

    handleExperienceSelected(experienceId) {
        this._recordId = experienceId;
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

    get isExperienceSelected() {
        return this._recordId;
    }

    get isNoExperienceSelected() {
        return !this._recordId;
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

    async handleBookSessionClick() {
        await LightningAlert.open({
            message: `This feature isn't implemented, check again later.`,
            theme: 'warn',
            label: 'Not Implemented'
        });
    }
}
