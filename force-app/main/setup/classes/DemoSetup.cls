public with sharing class DemoSetup {
    /**
     * Shifts all session experience dates to be arround demo date
     * Cleans bookings for Sofia
     */
    public static void run() {
        shiftExperienceSessionDates();
        cleanSofiasSessionBookings();
    }

    private static void shiftExperienceSessionDates() {
        AggregateResult[] results = [
            SELECT MIN(Date__c) minDate, MAX(Date__c) maxDate
            FROM Session__c
        ];
        Date minDate = (Date) results[0].get('minDate');
        Date maxDate = (Date) results[0].get('maxDate');
        if (minDate == null || maxDate == null) {
            return;
        }
        System.debug(
            'Session date range: ' +
                String.valueOf(minDate) +
                ' to ' +
                String.valueOf(maxDate)
        );

        Integer rangeSpanDays = minDate.daysBetween(maxDate);
        Date midDate = minDate.addDays(rangeSpanDays / 2);
        Integer offsetDays = midDate.daysBetween(Date.today());
        System.debug(
            'Offseting all dates by ' +
                offsetDays +
                ' days from ' +
                String.valueOf(midDate)
        );

        if (offsetDays != 0) {
            List<Session__c> sessions = [SELECT Id, Date__c FROM Session__c];
            for (Session__c session : sessions) {
                session.Date__c = session.Date__c.addDays(offsetDays);
            }
            System.debug('Updating ' + sessions.size() + ' sessions');
            update sessions;
        }
    }

    private static void cleanSofiasSessionBookings() {
        System.debug('Adjusting Sofia\'s bookings');
        // Find Sofia
        Contact sofia = [
            SELECT Id
            FROM Contact
            WHERE Name = 'Sofia Rodriguez'
            LIMIT 1
        ];
        // Remove Sofia's bookings
        delete [
            SELECT Id
            FROM Booking__c
            WHERE Contact__c = :sofia.Id
        ];
        // Add past bookings from 2 previous days
        for (Integer i = 0; i < 2; i++) {
            Date targetDate = Date.today().addDays(-i - 1);
            List<Session__c> sessions = [
                SELECT Id
                FROM Session__c
                WHERE Date__c = :targetDate
                LIMIT 100
            ];
            Session__c session = sessions[
                Integer.valueof((Math.random() * sessions.size()))
            ];
            insert new Booking__c(
                Contact__c = sofia.Id,
                Session__c = session.Id,
                Number_of_Guests__c = 1
            );
        }
    }
}
