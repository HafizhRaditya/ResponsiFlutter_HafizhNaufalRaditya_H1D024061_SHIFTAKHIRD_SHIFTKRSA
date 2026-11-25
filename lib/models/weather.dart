class CurrentWeather {
  final DateTime time;
  final double temperature;
  final int humidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final bool isDay;

  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature_2m'] as num).toDouble(),
      humidity: (json['relative_humidity_2m'] as num).toInt(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num? ?? 0).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
      isDay: (json['is_day'] as num? ?? 1) == 1,
    );
  }
}

class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double maxTemperature;
  final double minTemperature;
  final int? precipitationProbabilityMax;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemperature,
    required this.minTemperature,
    this.precipitationProbabilityMax,
  });
}

class Weather {
  final String timezone;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  const Weather({
    required this.timezone,
    required this.current,
    required this.daily,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final daily = json['daily'] as Map<String, dynamic>;
    final tanggal = List<String>.from(daily['time'] as List);
    final kode = daily['weather_code'] as List;
    final maks = daily['temperature_2m_max'] as List;
    final min = daily['temperature_2m_min'] as List;
    final peluang = daily['precipitation_probability_max'] as List;

    return Weather(
      timezone: json['timezone'] as String? ?? '-',
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      daily: [
        for (var i = 0; i < tanggal.length; i++)
          DailyForecast(
            date: DateTime.parse(tanggal[i]),
            weatherCode: (kode[i] as num? ?? 0).toInt(),
            maxTemperature: (maks[i] as num? ?? 0).toDouble(),
            minTemperature: (min[i] as num? ?? 0).toDouble(),
            precipitationProbabilityMax: (peluang[i] as num?)?.toInt(),
          ),
      ],
    );
  }

  int? get todayRainChance =>
      daily.isEmpty ? null : daily.first.precipitationProbabilityMax;
}
