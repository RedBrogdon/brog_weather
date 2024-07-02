library brog_weather;

import 'dart:async';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

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

  factory WeatherRecord.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'timestamp': String timestamp,
          'temperature': double temperature,
          'humidity': int humidity,
          'windSpeed': double windSpeed,
          'condition': String condition,
          'description': String description,
        }) {
      return WeatherRecord(
        timestamp: DateTime.parse(timestamp),
        temperature: temperature,
        humidity: humidity,
        windSpeed: windSpeed,
        condition: condition,
        description: description,
      );
    } else {
      throw const FormatException('Unexpected JSON!');
    }
  }
}

/// Interface for a streaming weather data service.
abstract class WeatherService {
  Stream<WeatherRecord> get weatherStream;
}

/// Let's all just pretend this is the real implementation of that service.
class LiveWeatherService {
  final _controller = StreamController<WeatherRecord>();
  Stream<WeatherRecord> get weatherStream => _controller.stream;
}

/// An offline-capable mock implementation that streams hardcoded data.
class MockWeatherService implements WeatherService {
  final weatherData = [
    WeatherRecord(
      timestamp: DateTime(1976, 11, 10, 23, 55),
      temperature: 18.5,
      humidity: 60,
      windSpeed: 15.2,
      condition: 'clear',
      description: 'Der Himmel ist klar und sternenklar.',
    ),
    WeatherRecord(
      timestamp: DateTime(1976, 11, 11, 0, 55),
      temperature: 18.0,
      humidity: 62,
      windSpeed: 14.8,
      condition: 'clear',
      description: 'Der Himmel ist wolkenlos.',
    ),
    WeatherRecord(
      timestamp: DateTime(1976, 11, 11, 1, 55),
      temperature: 17.8,
      humidity: 64,
      windSpeed: 14.5,
      condition: 'clear',
      description: 'Es gibt keine Wolken am Himmel.',
    ),
    WeatherRecord(
      timestamp: DateTime(1976, 11, 11, 2, 55),
      temperature: 17.5,
      humidity: 66,
      windSpeed: 14.2,
      condition: 'clear',
      description: 'Der Himmel ist heiter und sonnig.',
    ),
    WeatherRecord(
      timestamp: DateTime(1976, 11, 11, 3, 55),
      temperature: 17.3,
      humidity: 68,
      windSpeed: 13.9,
      condition: 'clear',
      description: 'Das Wetter ist angenehm und ruhig.',
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
