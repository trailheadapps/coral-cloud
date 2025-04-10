@IsTest
private class CheckWeatherTest {
    @IsTest
    static void testGetWeather_Success() {
        // Set up mock HTTP response
        String mockResponse = '{"weather": [{"temperature": 10.0},{"temperature": 30.0}]}';
        Test.setMock(
            HttpCalloutMock.class,
            new MockHttpResponse(200, mockResponse)
        );

        // Create test request
        CheckWeather.WeatherRequest request = new CheckWeather.WeatherRequest();
        request.dateToCheck = Date.today().addDays(1); // Tomorrow's date

        // Start test execution context
        Test.startTest();
        List<CheckWeather.WeatherResponse> responses = CheckWeather.getWeather(
            new List<CheckWeather.WeatherRequest>{ request }
        );
        Test.stopTest();

        // Verify response
        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.areEqual(
            10,
            responses[0].minTemperature,
            'Minimum temperature should be 10°C'
        );
        Assert.areEqual(
            30,
            responses[0].maxTemperature,
            'Maximum temperature should be 30°C'
        );
        Assert.areEqual(
            'Temperatures will be between 10.0°C (50.0°F) and 30.0°C (86.0°F) at Coral Cloud Resorts.',
            responses[0].temperatureDescription,
            'Temperature description should match expected format'
        );
    }

    private class MockHttpResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        public MockHttpResponse(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse res = new HttpResponse();
            res.setBody(body);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}
