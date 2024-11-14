public with sharing class SampleBookingBatch implements Database.Batchable<Session__c> {
    private List<Session__c> sessions;
    private List<Contact> contacts;
    private Map<Id, Integer> xpCapacities;

    @TestVisible
    private static final Decimal MIN_SESSION_FILL_PERCENT = 0.40;
    @TestVisible
    private static final Decimal MAX_SESSION_FILL_PERCENT = 0.75;

    public SampleBookingBatch(
        List<Experience__c> experiences,
        List<Session__c> sessions,
        List<Contact> contacts
    ) {
        this.sessions = sessions;
        this.contacts = contacts;
        // Get experience guest capacities
        this.xpCapacities = new Map<Id, Integer>();
        for (Experience__c experience : experiences) {
            this.xpCapacities.put(
                experience.Id,
                Integer.valueOf(experience.Capacity__c)
            );
        }
    }

    public Iterable<Session__c> start(Database.BatchableContext bc) {
        return this.sessions;
    }

    public void execute(
        Database.BatchableContext bc,
        List<Session__c> sessions
    ) {
        List<Booking__c> bookings = new List<Booking__c>();
        // Fill sessions
        for (Session__c session : sessions) {
            // Get session capacity based on experience
            Integer capacity = this.xpCapacities.get(session.Experience__c);

            // Calculate the booking target as a random value between 70% and 85% of capacity.
            Double targetPercentage =
                MIN_SESSION_FILL_PERCENT +
                (Math.random() *
                (MAX_SESSION_FILL_PERCENT - MIN_SESSION_FILL_PERCENT));
            Integer slotsToFill = Integer.valueOf(
                Math.ceil(capacity * targetPercentage)
            );

            // Fill session with random contacts
            while (slotsToFill > 0) {
                // Get random contact
                Integer randomIndex = Math.floor(
                        Math.random() * this.contacts.size()
                    )
                    .intValue();
                Contact contact = this.contacts.get(randomIndex);
                // Dynamically adjust the number of guests per booking based on remaining slots to fill and randomization
                Integer maxGuestsThisBooking = Math.min(6, slotsToFill);
                Integer numberOfGuests =
                    Math.floor(Math.random() * maxGuestsThisBooking)
                        .intValue() + 1;
                slotsToFill -= numberOfGuests;
                // Prepare booking record
                Booking__c booking = new Booking__c(
                    Contact__c = contact.Id,
                    Session__c = session.Id,
                    Number_of_Guests__c = numberOfGuests
                );
                bookings.add(booking);
            }
        }
        insert bookings;
    }

    public void finish(Database.BatchableContext bc) {
    }
}
