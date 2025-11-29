import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdvancedWeatherCard extends StatelessWidget {
  final String cityName;
  final String temperature;
  final String feelsLike;
  final String weatherDescription;
  final String iconUrl;

  final String minTemp;
  final String maxTemp;
  final String humidity;
  final String pressure;
  final String visibility;
  final String windSpeed;
  final String windDirection;
  final String sunrise;
  final String sunset;
  final String uvIndex;
  final String clouds;

  const AdvancedWeatherCard({
    super.key,
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.weatherDescription,
    required this.iconUrl,
    required this.minTemp,
    required this.maxTemp,
    required this.humidity,
    required this.pressure,
    required this.visibility,
    required this.windSpeed,
    required this.windDirection,
    required this.sunrise,
    required this.sunset,
    required this.uvIndex,
    required this.clouds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent.shade200,
            Colors.blue.shade600
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // TOP: City + Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cityName,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Image.network(
                iconUrl,
                width: 70,
                height: 70,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.cloud,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Temperature
          Text(
            temperature,
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          Text(
            "Feels like $feelsLike",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            weatherDescription,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          // Main Details Grid
          _buildGrid(),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _tile("Min Temp", minTemp),
            _tile("Max Temp", maxTemp),
            _tile("UV Index", uvIndex),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _tile("Humidity", humidity),
            _tile("Clouds", clouds),
            _tile("Pressure", pressure),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _tile("Visibility", visibility),
            _tile("Wind", "$windSpeed\n$windDirection"),
            _tile("Sunrise", sunrise),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _tile("Sunset", sunset),
            const SizedBox(width: 100), // for alignment
            const SizedBox(width: 100),
          ],
        ),
      ],
    );
  }

  Widget _tile(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
