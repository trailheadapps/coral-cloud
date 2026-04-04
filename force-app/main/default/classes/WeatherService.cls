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

        // Get the hourly temperatures
        List<Double> temperatures = new List<Double>();
        for (WeatherApiItemWrapper item : weatherResponse.weather) {
            if (item.temperature != null) {
                temperatures.add(item.temperature);
            }
        }
        temperatures.sort();

        // Prepare min and max temperatures and description
        Double minTempC = temperatures[0];
        Double maxTempC = temperatures[temperatures.size() - 1];
        Double minTempF = toFahrenheit(minTempC);
        Double maxTempF = toFahrenheit(maxTempC);
        String description =
            'On ' +
            dateString +
            ', temperature will be between ' +
            minTempC +
            '°C (' +
            minTempF +
            '°F) and ' +
            maxTempC +
            '°C (' +
            maxTempF +
            '°F) at Coral Cloud Resorts.';

        // Get the icon name
        String iconName = weatherResponse.weather[0].icon ?? 'clear-day';

        // Return weather info
        Weather weather = new Weather();
        weather.minTemperatureC = minTempC;
        weather.minTemperatureF = minTempF;
        weather.maxTemperatureC = maxTempC;
        weather.maxTemperatureF = maxTempF;
        weather.description = description;
        weather.iconName = iconName;
        return weather;
    }

    private static Double toFahrenheit(Double celsius) {
        Decimal value = Decimal.valueOf(celsius * 9 / 5 + 32).setScale(1);
        return value.doubleValue();
    }

    private class WeatherApiResponse {
        public List<WeatherApiItemWrapper> weather;
    }

    private class WeatherApiItemWrapper {
        public Double temperature;
        public String icon;
    }

    public class Weather {
        @InvocableVariable
        public Double minTemperatureC;
        @InvocableVariable
        public Double minTemperatureF;
        @InvocableVariable
        public Double maxTemperatureC;
        @InvocableVariable
        public Double maxTemperatureF;
        @InvocableVariable
        public String description;
        @InvocableVariable
        public String iconName;
    }
}
