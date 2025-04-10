@IsTest
private class DataTreeImporterTest {
    @IsTest
    static void testImportData_Success() {
        // Create mock HTTP callout responses
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Start test execution context
        Test.startTest();
        DataTreeImporter.importData();
        Test.stopTest();

        // Verify contacts were created
        List<Contact> contacts = [
            SELECT Id, LastName
            FROM Contact
            WITH USER_MODE
        ];
        Assert.areEqual(1, contacts.size(), 'Should have created one contact');
        Assert.areEqual(
            'Rodriguez',
            contacts[0].LastName,
            'Contact last name should be Rodriguez'
        );

        // Verify experiences were created
        List<Experience__c> experiences = [
            SELECT Id, Name
            FROM Experience__c
            WITH USER_MODE
        ];
        Assert.areEqual(
            1,
            experiences.size(),
            'Should have created one experience'
        );
        Assert.areEqual(
            'Tropical Snorkel Adventure',
            experiences[0].Name,
            'Experience name should match'
        );

        // Verify guest reviews were created
        List<Guest_Review__c> reviews = [
            SELECT Id
            FROM Guest_Review__c
            WITH USER_MODE
        ];
        Assert.areEqual(
            1,
            reviews.size(),
            'Should have created one guest review'
        );

        // Verify cases were created
        List<Case> cases = [SELECT Id FROM Case WITH USER_MODE];
        Assert.areEqual(1, cases.size(), 'Should have created one case');
    }

    @IsTest
    static void testImportData_HttpError() {
        // Create mock HTTP callout that returns an error
        Test.setMock(
            HttpCalloutMock.class,
            new MockHttpErrorResponseGenerator()
        );

        // Start test execution context
        Test.startTest();
        DataTreeImporter.importData();
        Test.stopTest();

        // Verify no records were created due to the error
        Assert.areEqual(
            0,
            [SELECT COUNT() FROM Contact WITH USER_MODE],
            'No contacts should be created'
        );
        Assert.areEqual(
            0,
            [SELECT COUNT() FROM Experience__c WITH USER_MODE],
            'No experiences should be created'
        );
        Assert.areEqual(
            0,
            [SELECT COUNT() FROM Guest_Review__c WITH USER_MODE],
            'No guest reviews should be created'
        );
        Assert.areEqual(
            0,
            [SELECT COUNT() FROM Case WITH USER_MODE],
            'No cases should be created'
        );
    }

    // Mock HTTP response generator for successful scenarios
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            String endpoint = req.getEndpoint();

            // Return different mock data based on the endpoint
            if (endpoint == DataTreeImporter.GITHUB_CONTACTS_URL) {
                res.setBody(
                    '{"records":[{"attributes": {"type": "Contact"}, "LastName":"Rodriguez", "FirstName":"Maria"}]}'
                );
            } else if (endpoint == DataTreeImporter.GITHUB_EXPERIENCE_URL) {
                res.setBody(
                    '{"records":[{"attributes": {"type": "Experience__c"}, "Name":"Tropical Snorkel Adventure"}]}'
                );
            } else if (endpoint == DataTreeImporter.GITHUB_GUEST_REVIEW_URL) {
                res.setBody(
                    '{"records":[{"attributes": {"type": "Guest_Review__c"}, "Rating__c":5, "Comment__c":"Amazing experience!"}]}'
                );
            } else if (endpoint == DataTreeImporter.GITHUB_CASE_URL) {
                res.setBody(
                    '{"records":[{"attributes": {"type": "Case"}, "Subject":"Test Case", "Description":"Test Description"}]}'
                );
            } else {
                res.setStatusCode(404);
                res.setBody('{"error":"Not Found"}');
            }

            return res;
        }
    }

    // Mock HTTP response generator for error scenarios
    private class MockHttpErrorResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(404);
            res.setBody('{"error":"Not Found"}');
            return res;
        }
    }
}
