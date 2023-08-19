import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TasksPieChart extends StatelessWidget {
  static const Color mainTextColor = Color.fromRGBO(51, 64, 84, 1);
  static const Color colorUrgent = Color.fromRGBO(255, 16, 102, 1);
  static const Color colorHigh = Color.fromRGBO(0, 224, 152, 1);
  static const Color colorNormal = Color.fromRGBO(215, 221, 230, 1);
  static const Color colorLow = Color.fromRGBO(0, 128, 255, 1);

  final int urgent;
  final int high;
  final int normal;
  final int low;

  const TasksPieChart({
    super.key,
    required this.urgent,
    required this.high,
    required this.normal,
    required this.low,
  });

  @override
  Widget build(BuildContext context) {
    int tasksNumber = urgent + high + normal + low;

    return SizedBox(
      height: 150,
      child: SfCircularChart(
        annotations: <CircularChartAnnotation>[
          CircularChartAnnotation(
            widget: Text(
              '$tasksNumber',
              style: const TextStyle(
                color: mainTextColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
        tooltipBehavior: TooltipBehavior(enable: true),
        legend: const Legend(isVisible: true),
        series: [
          DoughnutSeries<_ChartData, String>(
              dataSource: [
                _ChartData('Urgent', urgent, colorUrgent),
                _ChartData('High', high, colorHigh),
                _ChartData('Normal', normal, colorNormal),
                _ChartData('Low', low, colorLow),
              ],
              pointColorMapper: (_ChartData data, _) => data.color,
              xValueMapper: (_ChartData data, _) => '${data.x}: ${data.y}',
              yValueMapper: (_ChartData data, _) => data.y,
              name: 'Tasks'),
        ],
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.color);

  final String x;
  final int y;
  final Color color;
}
