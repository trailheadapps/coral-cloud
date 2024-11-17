public class WeatherService {
    /**
     * Gets the weather at Coral Cloud Resorts for the provided date
     * @param dateToCheck the date for which we're checking the weather
     * @return the weather information
     */
    public static Weather getResortWeather(Datetime dateToCheck) {
        // Copilot was trained in 2023 so it will use 2023 as the default year if
        // the user does not specify a year in their prompt. This means that we need
        // to adjust the input date to be on the current year.
        Integer currentYear = Date.today().year();
        Integer yearDelta = currentYear - dateToCheck.year();
        dateToCheck = dateToCheck.addYears(yearDelta);
        String isoDate = dateToCheck.format('yyyy-MM-dd');
        String dateString = dateToCheck.format('MMMM d');

        // Prepare API request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(
            'callout:Weather_Endpoint/weather?lat=37.789782764570425&lon=-122.39723702244089&date=' +
            isoDate
        );
        req.setMethod('GET');
        // Make callout
        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() != 200) {
            throw new CalloutException('Bad response: ' + res);
        }

        // The response contains a list of temperatures for different times of the day
        // We parse the response and find the min and max temperatures
        String body = res.getBody();
        WeatherApiResponse weatherResponse = (WeatherApiResponse) JSON.deserialize(
            body,
            WeatherAPIResponse.class
        );
        List<Decimal> temperatures = new List<Decimal>();
        for (TemperatureWrapper item : weatherResponse.weather) {
            if (item.temperature != null) {
                temperatures.add(item.temperature);
            }
        }
        temperatures.sort();

        // Prepare temperatures and description
        Decimal minTempC = temperatures[0];
        Decimal maxTempC = temperatures[temperatures.size() - 1];
        Decimal minTempF = toFahrenheit(minTempC);
        Decimal maxTempF = toFahrenheit(maxTempC);
        String description =
            'On ' +
            dateString +
            ', temperature should be between ' +
            minTempC +
            '°C (' +
            minTempF +
            '°F) and ' +
            maxTempC +
            '°C (' +
            maxTempF +
            '°F) at Coral Cloud Resorts.';

        // Return weather info
        Weather weather = new Weather();
        weather.minTemperatureC = minTempC;
        weather.minTemperatureF = minTempF;
        weather.maxTemperatureC = maxTempC;
        weather.maxTemperatureF = maxTempF;
        weather.description = description;
        return weather;
    }

    private static Decimal toFahrenheit(Decimal celsius) {
        return (celsius * 9 / 5 + 32).setScale(1);
    }

    private class WeatherApiResponse {
        public List<TemperatureWrapper> weather;
    }

    private class TemperatureWrapper {
        public Decimal temperature;
    }

    public class Weather {
        public Decimal minTemperatureC;
        public Decimal minTemperatureF;
        public Decimal maxTemperatureC;
        public Decimal maxTemperatureF;
        public String description;
    }
}
