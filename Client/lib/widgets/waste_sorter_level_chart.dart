import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:waste_free_home/models/waste_sorter_records.dart';

class WasteSorterLevelChart extends StatelessWidget {
  final List<WasteSorterLevelRecord> data;

  WasteSorterLevelChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final minX = data.first.timestamp.millisecondsSinceEpoch.toDouble();
    final maxX = data.last.timestamp.millisecondsSinceEpoch.toDouble();
    final interval = (maxX - minX) / 5;

    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      child: Text(
                        '${date.hour}:${date.minute}',
                        style: const TextStyle(
                          color: Color(0xff68737d),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                  interval: interval,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toString(),
                      style: const TextStyle(
                        color: Color(0xff67727d),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                  reservedSize: 28,
                  interval: 10, // Adjust the interval as needed
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: data.map((e) {
                  final timestampMs = e.timestamp.millisecondsSinceEpoch.toDouble();
                  final level = e.level;
                  if (timestampMs.isFinite && level.isFinite) {
                    return FlSpot(timestampMs, level);
                  } else {
                    return null;
                  }
                }).where((spot) => spot != null).cast<FlSpot>().toList(),
                isCurved: false,
                color: Colors.green,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
