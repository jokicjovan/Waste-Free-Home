import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:waste_free_home/models/thermo_humid_meter_records.dart';

class ThermoHumidMeterChart extends StatelessWidget {
  final List<ThermoHumidMeterRecord> data;

  const ThermoHumidMeterChart({super.key, required this.data});

  Widget _buildLegend({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Temperature data
    final temperatureSpots = data
        .map((e) {
      final timestampMs = e.timestamp.millisecondsSinceEpoch.toDouble();
      final temperature = e.temperature;
      if (timestampMs.isFinite && temperature.isFinite) {
        return FlSpot(timestampMs, temperature);
      } else {
        return null;
      }
    })
        .where((spot) => spot != null)
        .cast<FlSpot>()
        .toList();

    // Humidity data
    final humiditySpots = data
        .map((e) {
      final timestampMs = e.timestamp.millisecondsSinceEpoch.toDouble();
      final humidity = e.humidity;
      if (timestampMs.isFinite && humidity.isFinite) {
        return FlSpot(timestampMs, humidity);
      } else {
        return null;
      }
    })
        .where((spot) => spot != null)
        .cast<FlSpot>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(color: Colors.black),
                  bottom: BorderSide(color: Colors.black),
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${date.day}/${date.month}\n',
                                style: const TextStyle(
                                  color: Color(0xff68737d),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: '${date.year}',
                                style: const TextStyle(
                                  color: Color(0xff68737d),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          value.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          value.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  axisNameWidget: Text('Date',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      )),
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: temperatureSpots,
                  isCurved: false,
                  color: Colors.deepOrange,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: humiditySpots,
                  isCurved: false,
                  color: Colors.blue,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildLegend(color: Colors.deepOrange, text: 'Temperature'),
            const SizedBox(width: 16),
            _buildLegend(color: Colors.blue, text: 'Humidity'),
          ],
        ),
      ],
    );
  }
}
