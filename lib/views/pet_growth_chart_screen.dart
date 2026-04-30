import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

class PetGrowthChartScreen extends ConsumerStatefulWidget {
  const PetGrowthChartScreen({super.key});

  @override
  ConsumerState<PetGrowthChartScreen> createState() => _PetGrowthChartScreenState();
}

class _PetGrowthChartScreenState extends ConsumerState<PetGrowthChartScreen> {
  String _timeRange = '6M';
  final List<String> _ranges = ['3M', '6M', '1Y', 'ALL'];

  void _showLogMeasurementSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LogMeasurementSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Growth Tracking'),
            actions: [
              IconButton(
                onPressed: _showLogMeasurementSheet,
                icon: const Icon(Icons.add_chart_rounded),
                tooltip: 'Log Measurement',
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  _TimeRangeSelector(
                    selected: _timeRange,
                    ranges: _ranges,
                    onChanged: (val) => setState(() => _timeRange = val),
                  ),
                  const SizedBox(height: 24),
                  _ChartContainer(
                    title: 'Weight History',
                    unit: 'lbs',
                    chart: _WeightChart(timeRange: _timeRange),
                    trend: '+1.2 lbs this month',
                    trendColor: Colors.green,
                  ),
                  const SizedBox(height: 24),
                  _ChartContainer(
                    title: 'Height History',
                    unit: 'inches',
                    chart: _HeightChart(timeRange: _timeRange),
                    trend: 'Stable',
                    trendColor: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Milestones',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _MilestoneSliverList(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _MilestoneSliverList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final milestones = [
      {
        'title': 'Target Weight Reached',
        'date': 'Today',
        'icon': Icons.stars_rounded,
        'color': Colors.orange,
        'desc': 'Achieved optimal weight for breed standard.'
      },
      {
        'title': 'Ideal Height Achieved',
        'date': '2 weeks ago',
        'icon': Icons.straighten_rounded,
        'color': Colors.blue,
        'desc': 'Reached adult height milestone.'
      },
      {
        'title': 'Grown 5lbs since Jan',
        'date': '3 months ago',
        'icon': Icons.trending_up_rounded,
        'color': Colors.green,
        'desc': 'Consistent healthy growth pattern observed.'
      },
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final m = milestones[index];
          final colorScheme = Theme.of(context).colorScheme;
          final color = m['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(40),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outlineVariant.withAlpha(50),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(m['icon'] as IconData, size: 24, color: color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              m['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              m['date'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m['desc'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant.withAlpha(100),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: milestones.length,
      ),
    );
  }
}

class _TimeRangeSelector extends StatelessWidget {
  final String selected;
  final List<String> ranges;
  final ValueChanged<String> onChanged;

  const _TimeRangeSelector({
    required this.selected,
    required this.ranges,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: ranges.map((r) {
          final isSelected = selected == r;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  r,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final String unit;
  final String trend;
  final Color trendColor;
  final Widget chart;

  const _ChartContainer({
    required this.title,
    required this.unit,
    required this.chart,
    required this.trend,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(100)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(10),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Unit: $unit',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: trendColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trend.contains('+')
                          ? Icons.trending_up_rounded
                          : Icons.trending_flat_rounded,
                      size: 14,
                      color: trendColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        color: trendColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(height: 180, child: chart),
        ],
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final String timeRange;
  const _WeightChart({required this.timeRange});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant.withAlpha(40),
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 10),
              FlSpot(1, 12.5),
              FlSpot(2, 11.8),
              FlSpot(3, 14.2),
              FlSpot(4, 15.5),
              FlSpot(5, 16.8),
            ],
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 5,
                color: colorScheme.surface,
                strokeWidth: 2,
                strokeColor: colorScheme.primary,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withAlpha(50),
                  colorScheme.primary.withAlpha(0)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeightChart extends StatelessWidget {
  final String timeRange;
  const _HeightChart({required this.timeRange});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _group(0, 8, colorScheme),
          _group(1, 10, colorScheme),
          _group(2, 11, colorScheme),
          _group(3, 13, colorScheme),
          _group(4, 13.5, colorScheme),
          _group(5, 14, colorScheme),
        ],
      ),
    );
  }

  BarChartGroupData _group(int x, double y, ColorScheme cs) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: cs.secondary,
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 15,
            color: cs.surfaceContainerHighest.withAlpha(100),
          ),
        )
      ],
    );
  }
}

class _LogMeasurementSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Log Measurement',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 24),
          _MeasurementInput(
            label: 'Weight',
            unit: 'lbs',
            icon: Icons.fitness_center_rounded,
          ),
          const SizedBox(height: 16),
          _MeasurementInput(
            label: 'Height',
            unit: 'inches',
            icon: Icons.height_rounded,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Save Record',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementInput extends StatelessWidget {
  final String label;
  final String unit;
  final IconData icon;

  const _MeasurementInput({
    required this.label,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      keyboardType: TextInputType.number,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: '$label ($unit)',
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
        floatingLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
