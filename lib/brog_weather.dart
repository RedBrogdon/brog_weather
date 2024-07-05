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
      timestamp: DateTime(1976, 11, 10, 23, 0),
      temperature: 20.5,
      humidity: 55,
      windSpeed: 15.2,
      condition: 'Clear',
      description: 'Der Himmel ist klar und sternenklar.',
    ),
    WeatherRecord(
      timestamp: DateTime(1976, 11, 10, 23, 1),
      temperature: 20.3,
      humidity: 57,
      windSpeed: 14.8,
      condition: 'Clear',
      description: 'Der Himmel ist klar und es ist eine leichte Brise.',
    ),
    WeatherRecord(
      timestamp: DateTime(1976, 11, 10, 23, 2),
      temperature: 20.1,
      humidity: 59,
      windSpeed: 14.5,
      condition: 'Clear',
      description: 'Der Himmel ist klar und es ist eine angenehme Temperatur.',
    ),
    WeatherRecord(
      timestamp: DateTime(1976, 11, 10, 23, 3),
      temperature: 19.9,
      humidity: 61,
      windSpeed: 14.2,
      condition: 'Clear',
      description: 'Der Himmel ist klar und es ist ein bisschen kühl.',
    ),
    WeatherRecord(
      timestamp: DateTime(1976, 11, 10, 23, 4),
      temperature: 19.7,
      humidity: 63,
      windSpeed: 13.9,
      condition: 'Clear',
      description: 'Der Himmel ist klar und es ist eine ruhige Nacht.',
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

/// A generative AI-backed mock that streams data created on the fly.
class GenerativeMockWeatherService implements WeatherService {
  final String apiKey;

  late final GenerativeModel model;

  late final PromptCreator _promptCreator;

  final generationConfig = GenerationConfig(
    temperature: 1.0,
    topP: 1,
    maxOutputTokens: 65535,
    responseMimeType: 'application/json',
  );

  final safetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
  ];

  GenerativeMockWeatherService({
    required String place,
    required DateTime timestamp,
    required this.apiKey,
  }) {
    model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    _promptCreator = PromptCreator(place, timestamp);
  }

  Future<List<WeatherRecord>> _generateRecords() async {
    try {
      final response = await model.generateContent(
        [Content.text(_promptCreator.prompt)],
      );

      final decoded = jsonDecode(response.text ?? '');
      final records = <WeatherRecord>[];
      for (final item in decoded) {
        records.add(WeatherRecord.fromJson(item));
      }

      return records;
    } catch (ex) {
      print(ex.toString());
    }

    throw 'Could not parse JSON!';
  }

  @override
  Stream<WeatherRecord> get weatherStream async* {
    final weatherData = await _generateRecords();
    for (final data in weatherData) {
      yield data;
      await Future.delayed(const Duration(seconds: 3));
    }
  }
}

class PromptCreator {
  final String place;
  final DateTime timestamp;

  PromptCreator(this.place, this.timestamp);

  String get formattedDate {
    final formatter = DateFormat.yMMMMd('en_US').add_jm();
    return formatter.format(timestamp);
  }

  String get prompt {
    return '''
You are an expert Dart and Flutter coder.
Here is a Dart class designed to contain weather data:

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

Create a JSON that can be easily converted into a list of 5 WeatherRecord objects containing fake weather data records.
Use arbitrary, constant data instead of random values.
Respond only with JSON, and do not include markdown.
Each record should be for an hour after the previous one.
Weather should not vary too much from one record to another.
Weather data should for $formattedDate
and the place is $place.
Don't mention the location in the description.
The description should be in German.''';
  }
}
