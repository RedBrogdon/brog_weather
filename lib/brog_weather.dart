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
    int count = 0;
    while (count < 3) {
      try {
        final response = await model.generateContent(
          [Content.text(_promptCreator.prompt)],
          safetySettings: safetySettings,
          generationConfig: generationConfig,
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

      count++;
    }

    throw 'Could not parse JSON after 3 tries';
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

  String get formattedDate {
    final DateFormat formatter = DateFormat.yMMMMd('en_US').add_jm();
    return formatter.format(timestamp);
  }

  const PromptCreator(this.place, this.timestamp);

  String get prompt {
    return '''
You are an expert Dart and Flutter developer.

This is the definition of a Dart class that contains data about weather
conditions:

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

Create a JSON list with five records that can be converted into a list of
WeatherRecord objects containing fake weather data.

Use arbitrary, constant data, rather than randomly generated values.

Respond only with JSON.

Each record should be for a time one hour after the previous record.

The weather data in each object should not vary much from one record to the
next.

The timestamp for the first record should be $formattedDate
and the weather data should be for $place.

Do not mention the location in the description field. 

Text in the description field should be in German.
''';
  }
}

const dummy = '''
[
  {
    "timestamp": "1976-11-10T23:55:00.000Z",
    "temperature": 18.5,
    "humidity": 55,
    "windSpeed": 15.0,
    "condition": "clear",
    "description": "Klare Nacht mit leichtem Wind."
  },
  {
    "timestamp": "1976-11-11T00:55:00.000Z",
    "temperature": 17.8,
    "humidity": 58,
    "windSpeed": 14.5,
    "condition": "clear",
    "description": "Der Himmel ist sternenklar."
  },
  {
    "timestamp": "1976-11-11T01:55:00.000Z",
    "temperature": 17.2,
    "humidity": 62,
    "windSpeed": 14.0,
    "condition": "partly cloudy",
    "description": "Ein paar Wolken ziehen über den Himmel."
  },
  {
    "timestamp": "1976-11-11T02:55:00.000Z",
    "temperature": 16.7,
    "humidity": 65,
    "windSpeed": 13.5,
    "condition": "partly cloudy",
    "description": "Es ist leicht bewölkt."
  },
  {
    "timestamp": "1976-11-11T03:55:00.000Z",
    "temperature": 16.2,
    "humidity": 68,
    "windSpeed": 13.0,
    "condition": "cloudy",
    "description": "Der Himmel ist bedeckt mit Wolken."
  }
]
''';
