import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:waste_free_home/models/waste_sorter_records.dart';

class WasteSorterLevelChart extends StatelessWidget {
  final List<WasteSorterLevelRecord> data;

  const WasteSorterLevelChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

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
                      }),
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
                rightTitles: const AxisTitles(
                  axisNameWidget: Text('Capacity filled (%)',
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
                  spots: data
                      .map((e) {
                    final timestampMs =
                    e.timestamp.millisecondsSinceEpoch.toDouble();
                    final level = e.recyclableLevel;
                    if (timestampMs.isFinite && level.isFinite) {
                      return FlSpot(timestampMs, level);
                    } else {
                      return null;
                    }
                  })
                      .where((spot) => spot != null)
                      .cast<FlSpot>()
                      .toList(),
                  isCurved: false,
                  color: Colors.orange,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: data
                      .map((e) {
                    final timestampMs =
                    e.timestamp.millisecondsSinceEpoch.toDouble();
                    final level = e.nonRecyclableLevel;
                    if (timestampMs.isFinite && level.isFinite) {
                      return FlSpot(timestampMs, level);
                    } else {
                      return null;
                    }
                  })
                      .where((spot) => spot != null)
                      .cast<FlSpot>()
                      .toList(),
                  isCurved: false,
                  color: Colors.grey,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8), // Space between chart and legend
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildLegend(color: Colors.orange, text: 'Recyclable'),
              const SizedBox(width: 16),
              _buildLegend(color: Colors.grey, text: 'Non-Recyclable'),
            ],
          ),
        ),
      ],
    );
  }

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
}
