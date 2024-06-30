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
  final weatherData = [];

  @override
  Stream<WeatherRecord> get weatherStream async* {
    for (final data in weatherData) {
      yield data;
      await Future.delayed(const Duration(seconds: 3));
    }
  }
}
