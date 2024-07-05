import 'package:brog_weather/brog_weather.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const place = 'Mars';

  late final WeatherService _service;

  late final Stream<WeatherRecord> _weatherStream;

  @override
  void initState() {
    super.initState();

    const apiKey =
        String.fromEnvironment('API_KEY', defaultValue: 'key not found');
    if (apiKey == 'key not found') {
      throw 'Key not found in environment. Please add an API key.';
    }

    _service = GenerativeMockWeatherService(
      place: place,
      timestamp: DateTime.now(),
      apiKey: apiKey,
    );

    _weatherStream = _service.weatherStream.asBroadcastStream();
  }

  Widget _buildDisplay(WeatherRecord weather) {
    final valueStyle = Theme.of(context).textTheme.titleLarge!;
    final labelStyle = valueStyle.copyWith(fontWeight: FontWeight.bold);

    return SizedBox.expand(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Temperature',
                style: labelStyle,
              ),
              const SizedBox(height: 8),
              Text(
                '${weather.temperature}',
                style: valueStyle,
              ),
              const SizedBox(height: 32),
              Text(
                'Condition',
                style: labelStyle,
              ),
              const SizedBox(height: 8),
              Text(
                weather.condition,
                style: valueStyle,
              ),
              const SizedBox(height: 32),
              Text(
                'Humidity',
                style: labelStyle,
              ),
              const SizedBox(height: 8),
              Text(
                '${weather.humidity}',
                style: valueStyle,
              ),
              const SizedBox(height: 32),
              Text(
                'Wind speed',
                style: labelStyle,
              ),
              const SizedBox(height: 8),
              Text(
                '${weather.windSpeed}',
                style: valueStyle,
              ),
              const SizedBox(height: 32),
              Text(
                'Description',
                style: labelStyle,
              ),
              const SizedBox(height: 8),
              Text(
                weather.description,
                style: valueStyle,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(Object? error) {
    return Center(
      child: Text(
        'Error :(',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Weather for $place'),
      ),
      body: StreamBuilder(
        stream: _weatherStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildDisplay(snapshot.data!);
          } else if (snapshot.hasError) {
            debugPrint(snapshot.error?.toString());
            return _buildError(snapshot.error);
          }

          return _buildPlaceholder();
        },
      ),
    );
  }
}
