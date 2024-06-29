library brog_weather;

import 'dart:async';

class WeatherRecord {
  final DateTime timestamp;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String condition;
  final String description;

  WeatherRecord({
    /// The time the record was recorded.
    required this.timestamp,

    /// The ambient temperature in degrees Celsius.
    required this.temperature,

    /// Humidity in percent.
    required this.humidity,

    /// Wind speed in kilometers/hour.
    required this.windSpeed,

    /// A one- or two-word weather condition like "sunny" or "partly cloudy".
    required this.condition,

    /// A one-sentence description of the weather.
    required this.description,
  });
}

/// A Calculator.
abstract class WeatherService {
  Stream<WeatherRecord> get weatherStream;
}

class LiveWeatherService {
  final _controller = StreamController<WeatherRecord>();

  Stream<WeatherRecord> get weatherStream => _controller.stream;
}

class MockWeatherService implements WeatherService {
  final weatherData = [
    WeatherRecord(
      timestamp: DateTime(1976, 11, 10, 23, 55),
      temperature: 18.3,
      humidity: 55,
      windSpeed: 15.0,
      condition: 'Clear',
      description: 'Clear skies with a gentle breeze.',
    ),
    WeatherRecord(
      timestamp: DateTime(1976, 11, 10, 23, 55).add(const Duration(hours: 1)),
      temperature: 17.8,
      humidity: 57,
      windSpeed: 14.5,
      condition: 'Clear',
      description: 'A clear and cool night.',
    ),
    WeatherRecord(
      timestamp: DateTime(1976, 11, 10, 23, 55).add(const Duration(hours: 2)),
      temperature: 17.3,
      humidity: 59,
      windSpeed: 14.0,
      condition: 'Partly Cloudy',
      description: 'A few clouds have moved in, but the night remains clear.',
    ),
    WeatherRecord(
      timestamp: DateTime(1976, 11, 10, 23, 55).add(const Duration(hours: 3)),
      temperature: 16.8,
      humidity: 61,
      windSpeed: 13.5,
      condition: 'Partly Cloudy',
      description: 'The skies are becoming slightly more overcast.',
    ),
    WeatherRecord(
      timestamp: DateTime(1976, 11, 10, 23, 55).add(const Duration(hours: 4)),
      temperature: 16.3,
      humidity: 63,
      windSpeed: 13.0,
      condition: 'Partly Cloudy',
      description:
          'The sky is mostly cloudy, but a few stars are still visible.',
    ),
  ];

  @override
  Stream<WeatherRecord> get weatherStream async* {
    for (final data in weatherData) {
      yield data;
      await Future.delayed(const Duration(seconds: 3));
    }
  }
}
