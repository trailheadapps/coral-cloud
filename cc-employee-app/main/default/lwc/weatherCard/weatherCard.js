import { LightningElement, api } from 'lwc';

// Base location for weather icons
const BASE_ICON_PATH =
    'https://s3-us-west-2.amazonaws.com/dev-or-devrl-s3-bucket/sample-apps/coral-clouds/weather-icons';

export default class WeatherCard extends LightningElement {
    @api
    value;

    unit = 'celsius';

    handleUnitChange(event) {
        this.unit = event.detail.value;
    }

    get unitOptions() {
        return [
            { label: '°C', value: 'celsius' },
            { label: '°F', value: 'fahrenheit' }
        ];
    }

    get imageSrc() {
        const iconName = this.value?.iconName || 'clear-day';
        return `${BASE_ICON_PATH}/${iconName}.jpg`;
    }

    get minTemp() {
        if (this.unit === 'celsius') {
            return `${this.value?.minTemperatureC || '-'} °C`;
        }
        return `${this.value?.minTemperatureF || '-'} °F`;
    }

    get maxTemp() {
        if (this.unit === 'celsius') {
            return `${this.value?.maxTemperature || '-'} °C`;
        }
        return `${this.value?.maxTemperatureF || '-'} °F`;
    }
}
