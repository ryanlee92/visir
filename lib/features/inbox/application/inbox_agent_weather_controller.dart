import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/flavors.dart';
import 'package:change_case/change_case.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons_full.dart';
import 'package:ipwhois/ipwhois.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weather_kit/weather_kit.dart';

part 'inbox_agent_weather_controller.g.dart';

enum WeatherCondition { clear, cloudy, fog, rain, snow }

extension WeatherConditionX on WeatherCondition {
  String get assets {
    switch (this) {
      case WeatherCondition.clear:
        return 'assets/background/background_clear_${Utils.mainContext.isDarkMode ? 'night' : 'day'}.png';
      case WeatherCondition.cloudy:
        return 'assets/background/background_cloudy_${Utils.mainContext.isDarkMode ? 'night' : 'day'}.png';
      case WeatherCondition.fog:
        return 'assets/background/background_fog_${Utils.mainContext.isDarkMode ? 'night' : 'day'}.png';
      case WeatherCondition.rain:
        return 'assets/background/background_rain_${Utils.mainContext.isDarkMode ? 'night' : 'day'}.png';
      case WeatherCondition.snow:
        return 'assets/background/background_snow_${Utils.mainContext.isDarkMode ? 'night' : 'day'}.png';
    }
  }
}

class Weather {
  final double celcius;
  final WeatherCondition condition;
  final List<List<dynamic>> icon;
  final String name;
  final bool useFahrenheit;

  double get temperature => useFahrenheit ? celcius * 9 / 5 + 32 : celcius;

  Weather({required this.celcius, required this.condition, required this.icon, required this.name, required this.useFahrenheit});
}

@riverpod
class InboxAgentWeatherController extends _$InboxAgentWeatherController {
  Timer? _periodicTimer;
  bool _disposed = false;

  @override
  Weather? build() {
    // appConfigProvider가 완료될 때까지 대기
    ref.listen(appConfigProvider, (previous, next) {
      if (next.hasValue && !_disposed) {
        // appConfigProvider가 완료되면 refresh 호출
        refresh().catchError((e, stackTrace) {
          // 에러 무시
        });
        // 주기적 refresh 시작
        _periodicTimer?.cancel();
        _periodicTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
          if (!_disposed) {
            refresh().catchError((e, stackTrace) {
              // 에러 무시
            });
          } else {
            timer.cancel();
          }
        });
      }
    });

    // appConfigProvider가 이미 완료되어 있으면 즉시 refresh
    final appConfigAsync = ref.read(appConfigProvider);
    if (appConfigAsync.hasValue) {
      refresh().catchError((e, stackTrace) {
        // 에러 무시
      });
      _periodicTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
        if (!_disposed) {
          refresh().catchError((e, stackTrace) {
            // 에러 무시
          });
        } else {
          timer.cancel();
        }
      });
    }

    ref.onDispose(() {
      _disposed = true;
      _periodicTimer?.cancel();
    });

    return null;
  }

  Future<void> refresh() async {
    if (_disposed) {
      return;
    }

    try {
      final IpInfo? resultV4 = await getMyIpInfo();
      if (resultV4 == null || resultV4.countryCode == null || resultV4.latitude == null || resultV4.longitude == null) {
        if (!_disposed) {
          state = Weather(celcius: 0, condition: WeatherCondition.clear, icon: HugeIcons.strokeRoundedSun01, name: 'N/A', useFahrenheit: false);
        }
        return;
      }

      final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
      final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);

      // Edge Function에서 가져온 키 사용, 없으면 config.json에서 가져오기 (fallback)
      final finalAppleKey = appleKey.isNotEmpty ? appleKey : env.appleKey;
      var finalApplePem = applePem.isNotEmpty ? applePem : env.applePem;

      // PEM 키의 이스케이프된 줄바꿈 문자를 실제 줄바꿈 문자로 변환
      // JSON에서 가져온 경우 \n이 리터럴 문자열로 저장될 수 있음
      finalApplePem = finalApplePem.replaceAll('\\n', '\n');

      // PEM 키가 비어있거나 유효하지 않으면 기본값 반환
      if (finalAppleKey.isEmpty || finalApplePem.isEmpty) {
        if (!_disposed) {
          state = Weather(celcius: 0, condition: WeatherCondition.clear, icon: HugeIcons.strokeRoundedSun01, name: 'N/A', useFahrenheit: false);
        }
        return;
      }

      // PEM 키 형식 검증 (최소한 BEGIN/END 헤더가 있어야 함)
      final hasBeginHeader = finalApplePem.contains('-----BEGIN');
      final hasEndHeader = finalApplePem.contains('-----END');
      if (!hasBeginHeader || !hasEndHeader) {
        if (!_disposed) {
          state = Weather(celcius: 0, condition: WeatherCondition.clear, icon: HugeIcons.strokeRoundedSun01, name: 'N/A', useFahrenheit: false);
        }
        return;
      }

      // PEM 키 최소 길이 검증 (너무 짧으면 파싱 에러 발생 가능)
      if (finalApplePem.length < 100) {
        if (!_disposed) {
          state = Weather(celcius: 0, condition: WeatherCondition.clear, icon: HugeIcons.strokeRoundedSun01, name: 'N/A', useFahrenheit: false);
        }
        return;
      }

      String token;
      try {
        final weatherKit = WeatherKit();
        token = weatherKit.generateJWT(bundleId: env.appleBundleId, teamId: env.appleTeamId, keyId: finalAppleKey, pem: finalApplePem, expiresIn: const Duration(hours: 1));
      } catch (e) {
        if (!_disposed) {
          state = Weather(celcius: 0, condition: WeatherCondition.clear, icon: HugeIcons.strokeRoundedSun01, name: 'N/A', useFahrenheit: false);
        }
        return;
      }

      final url = 'https://weatherkit.apple.com/api/v1/weather/en/${resultV4.latitude}/${resultV4.longitude}?dataSets=currentWeather&countryCode=${resultV4.countryCode}';
      final result = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});

      if (!_disposed && result.statusCode == 200) {
        final body = jsonDecode(result.body);
        final currentWeather = body['currentWeather']?['conditionCode'] as String?;
        final celcius = body['currentWeather']?['temperature'] as double?;

        if (currentWeather != null && currentWeather.isNotEmpty && celcius != null) {
          try {
            final camelCase = currentWeather.toCamelCase();
            final sentenceCase = currentWeather.toSentenceCase();
            
            state = Weather(
              celcius: celcius,
              condition: _mapCondition(camelCase),
              icon: _mapIcon(camelCase),
              name: sentenceCase,
              useFahrenheit: resultV4.countryCode == 'US',
            );
          } catch (e) {
            if (!_disposed) {
              state = Weather(celcius: 0, condition: WeatherCondition.clear, icon: HugeIcons.strokeRoundedSun01, name: 'N/A', useFahrenheit: false);
            }
          }
        } else {
          if (!_disposed) {
            state = Weather(celcius: 0, condition: WeatherCondition.clear, icon: HugeIcons.strokeRoundedSun01, name: 'N/A', useFahrenheit: false);
          }
        }
      } else {
        if (!_disposed) {
          state = Weather(celcius: 0, condition: WeatherCondition.clear, icon: HugeIcons.strokeRoundedSun01, name: 'N/A', useFahrenheit: false);
        }
      }
    } catch (e) {
      if (!_disposed) {
        state = Weather(celcius: 0, condition: WeatherCondition.clear, icon: HugeIcons.strokeRoundedSun01, name: 'N/A', useFahrenheit: false);
      }
    }
  }

  List<List<dynamic>> _mapIcon(String condition) {
    switch (condition) {
      case 'clear':
      case 'mostlyClear':
        return HugeIcons.duotoneRoundedSun01;
      case 'partlyCloudy':
        return HugeIcons.duotoneRoundedSunCloud02;
      case 'cloudy':
      case 'mostlyCloudy':
        return HugeIcons.duotoneRoundedCloud;
      case 'breezy':
      case 'windy':
        return HugeIcons.duotoneRoundedFastWind;
      case 'fog':
      case 'haze':
        return HugeIcons.duotoneRoundedSlowWinds;
      case 'drizzle':
        return HugeIcons.duotoneRoundedCloudLittleRain;
      case 'rain':
      case 'rainShowers':
        return HugeIcons.duotoneRoundedCloudMidRain;
      case 'heavyRain':
        return HugeIcons.duotoneRoundedCloudAngledRain;
      case 'thunderstorms':
        return HugeIcons.duotoneRoundedCloudAngledRainZap;
      case 'hurricane':
        return HugeIcons.duotoneRoundedTornado02;
      case 'tropicalStorm':
        return HugeIcons.duotoneRoundedTropicalStorm;
      case 'snow':
      case 'snowShowers':
      case 'flurries':
      case 'sunFlurries':
        return HugeIcons.duotoneRoundedCloudSnow;
      case 'sleet':
      case 'freezingDrizzle':
      case 'freezingRain':
      case 'wintryMix':
        return HugeIcons.duotoneRoundedCloudLittleSnow;
      case 'blizzard':
      case 'blowingSnow':
      case 'frigid':
      case 'hail':
        return HugeIcons.duotoneRoundedSnow;
      case 'blowingDust':
      case 'smoky':
        return HugeIcons.duotoneRoundedCloudSlowWind;
      default:
        return HugeIcons.duotoneRoundedSun01;
    }
  }

  WeatherCondition _mapCondition(String condition) {
    switch (condition) {
      case 'clear':
      case 'mostlyClear':
        return WeatherCondition.clear;
      case 'partlyCloudy':
      case 'cloudy':
      case 'mostlyCloudy':
      case 'breezy':
      case 'windy':
        return WeatherCondition.cloudy;
      case 'fog':
      case 'haze':
      case 'blowingDust':
      case 'smoky':
        return WeatherCondition.fog;
      case 'drizzle':
      case 'rain':
      case 'heavyRain':
      case 'rainShowers':
      case 'thunderstorms':
      case 'hurricane':
      case 'tropicalStorm':
        return WeatherCondition.rain;
      case 'snow':
      case 'snowShowers':
      case 'sleet':
      case 'freezingDrizzle':
      case 'freezingRain':
      case 'flurries':
      case 'sunFlurries':
      case 'wintryMix':
      case 'blizzard':
      case 'blowingSnow':
      case 'frigid':
      case 'hail':
        return WeatherCondition.snow;
      default:
        return WeatherCondition.clear;
    }
  }
}
