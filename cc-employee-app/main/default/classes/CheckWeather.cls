public with sharing class CheckWeather {
    @InvocableMethod(
        label='Check Weather'
        description='Check weather at Coral Cloud Resorts at a specific date. The date must be in the future, not today or earlier.'
    )
    public static List<WeatherResponse> getWeather(
        List<WeatherRequest> requests
    ) {
        // Retrieve the date for which we want to check the weather
        Datetime dateToCheck = (Datetime) requests[0].dateToCheck;

        WeatherResponse response = new WeatherResponse();
        //response.weather = WeatherService.getResortWeather(dateToCheck);

        response.weather = new Weather();
        response.weather.minTemperatureC = 20;
        response.weather.minTemperatureF = 68;
        response.weather.maxTemperatureC = 30;
        response.weather.maxTemperatureF = 86;
        response.weather.description = 'Sunny with a high of 70°F and a low of 50°F';
        response.weather.iconName = 'clear-day';

        return new List<WeatherResponse>{ response };
    }

    public class WeatherRequest {
        @InvocableVariable(
            required=true
            description='Date for which we want to check the weather. The variable needs to be an Apex Date type with format yyyy-MM-dd.'
        )
        public Date dateToCheck;
    }

    public class WeatherResponse {
        @InvocableVariable(description='Weather details for the provided date')
        public Weather weather;
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
