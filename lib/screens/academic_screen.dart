import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/student.dart';

class AcademicScreen extends StatefulWidget {
  final Student student;

  const AcademicScreen({super.key, required this.student});

  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends State<AcademicScreen> {
  late Student _student;
  String _selectedSemester = 'all';

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  List<String> get _semesters {
    Set<String> semesters = {};
    for (var grade in _student.grades) {
      semesters.add(grade.semester);
    }
    return ['all', ...semesters.toList()..sort()];
  }

  List get _filteredGrades {
    if (_selectedSemester == 'all') {
      return _student.grades;
    }
    return _student.grades
        .where((g) => g.semester == _selectedSemester)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bảng Điểm & Thống Kê'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'Điểm môn học'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Biểu đồ'),
              Tab(icon: Icon(Icons.trending_up), text: 'Thống kê'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Scorecard ListView
            _buildScoreTab(),
            // Tab 2: Charts
            _buildChartTab(),
            // Tab 3: Statistics
            _buildStatisticsTab(),
          ],
        ),
      ),
    );
  }

  // ============ TAB 1: BẢNG ĐIỂM ============
  Widget _buildScoreTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // GPA Summary Card
          _buildGpaSummaryCard(),

          // Semester Filter
          _buildSemesterFilter(),

          // Scores List
          _buildScoresList(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGpaSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo, Colors.indigoAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Kết quả học tập',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGpaItem(
                'GPA 10',
                _student.gpa10Weighted.toString(),
                Colors.white,
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildGpaItem('GPA 4', _student.gpa4.toString(), Colors.white),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildGpaItem('Xếp loại', _student.classification, Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGpaItem(String label, String value, Color textColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: _semesters.map((semester) {
          final isSelected = _selectedSemester == semester;
          final label = semester == 'all' ? 'Tất cả' : 'Kì $semester';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(label),
              onSelected: (selected) {
                setState(() => _selectedSemester = semester);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.indigo,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScoresList() {
    final grades = _filteredGrades;

    if (grades.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'Không có dữ liệu điểm',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grades.length,
      itemBuilder: (context, index) {
        final grade = grades[index];
        return _buildGradeCard(grade);
      },
    );
  }

  Widget _buildGradeCard(dynamic grade) {
    final scoreColor = grade.score >= 8.0
        ? Colors.green
        : grade.score >= 7.0
        ? Colors.blue
        : grade.score >= 6.0
        ? Colors.amber
        : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Score Badge
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      grade.score.toString(),
                      style: TextStyle(
                        color: scoreColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/10',
                      style: TextStyle(
                        color: scoreColor.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Subject Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grade.subjectName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tín chỉ: ${grade.credits}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Điểm 4.0: ${grade.scoreIn4.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: scoreColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ TAB 2: BIỂU ĐỒ ============
  Widget _buildChartTab() {
    final semesters = _semesters.where((s) => s != 'all').toList();

    if (semesters.isEmpty) {
      return const Center(child: Text('Không có dữ liệu để hiển thị biểu đồ'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // GPA Trend Chart
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xu hướng GPA theo kì',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildGpaTrendChart(semesters),
              ],
            ),
          ),
          // Score Comparison Chart
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Biểu đồ điểm các môn học (Kì gần nhất)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildScoreComparisonChart(),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGpaTrendChart(List<String> semesters) {
    final chartData = semesters.asMap().entries.map((entry) {
      final semester = entry.value;
      final gpa = _student.gpaBySemester[semester] ?? 0.0;
      return FlSpot(entry.key.toDouble(), gpa);
    }).toList();

    // Calculate min and max for Y axis
    final maxGpa =
        (chartData.isEmpty
                ? 0
                : chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b))
            .ceil()
            .toDouble();

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < semesters.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text('Kì ${semesters[value.toInt()]}'),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toStringAsFixed(1));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          minY: 0,
          maxY: maxGpa > 4 ? maxGpa : 4,
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: true,
              color: Colors.indigo,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: Colors.indigo,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.indigo.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreComparisonChart() {
    final lastSemester =
        _semesters.where((s) => s != 'all').toList().lastOrNull ?? '1';
    final gradesInSemester = _student.grades
        .where((g) => g.semester == lastSemester)
        .toList();

    if (gradesInSemester.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Không có dữ liệu')),
      );
    }

    final chartData = gradesInSemester.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.score,
            color: _getScoreColor(entry.value.score),
            width: 20,
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: chartData,
          maxY: 10,
          minY: 0,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < gradesInSemester.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        gradesInSemester[index].subjectName.substring(
                          0,
                          gradesInSemester[index].subjectName.length > 10
                              ? 10
                              : gradesInSemester[index].subjectName.length,
                        ),
                        style: const TextStyle(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toStringAsFixed(0));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 7.0) return Colors.blue;
    if (score >= 6.0) return Colors.amber;
    return Colors.red;
  }

  // ============ TAB 3: THỐNG KÊ ============
  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Overall Statistics
          _buildStatisticsCard(
            title: 'Thống kê tổng quan',
            items: [
              _StatisticItem(
                label: 'Tổng số môn học',
                value: _student.grades.length.toString(),
                icon: Icons.school,
              ),
              _StatisticItem(
                label: 'Tổng tín chỉ',
                value: _student.grades
                    .fold(0, (sum, g) => sum + g.credits)
                    .toString(),
                icon: Icons.credit_card,
              ),
              _StatisticItem(
                label: 'Số môn xuất sắc (≥8.5)',
                value: _student.grades
                    .where((g) => g.score >= 8.5)
                    .length
                    .toString(),
                icon: Icons.star,
                color: Colors.amber,
              ),
              _StatisticItem(
                label: 'Số môn yếu (<5)',
                value: _student.grades
                    .where((g) => g.score < 5)
                    .length
                    .toString(),
                icon: Icons.warning_amber,
                color: Colors.red,
              ),
            ],
          ),
          // Per Semester Statistics
          ..._semesters.where((s) => s != 'all').map((semester) {
            final gradesInSemester = _student.grades
                .where((g) => g.semester == semester)
                .toList();
            final avgScore = gradesInSemester.isEmpty
                ? 0.0
                : gradesInSemester.fold(0.0, (sum, g) => sum + g.score) /
                      gradesInSemester.length;
            final totalCredits = gradesInSemester.fold(
              0,
              (sum, g) => sum + g.credits,
            );

            return _buildStatisticsCard(
              title: 'Kì $semester',
              items: [
                _StatisticItem(
                  label: 'Số môn học',
                  value: gradesInSemester.length.toString(),
                  icon: Icons.assessment,
                ),
                _StatisticItem(
                  label: 'Điểm TB',
                  value: avgScore.toStringAsFixed(2),
                  icon: Icons.trending_up,
                ),
                _StatisticItem(
                  label: 'Tín chỉ',
                  value: totalCredits.toString(),
                  icon: Icons.credit_card,
                ),
                _StatisticItem(
                  label: 'GPA 4.0',
                  value: (_student.gpaBySemester[semester] ?? 0.0)
                      .toStringAsFixed(2),
                  icon: Icons.grade,
                  color: Colors.indigo,
                ),
              ],
            );
          }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard({
    required String title,
    required List<_StatisticItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          GridView.builder(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildStatisticTile(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticTile(_StatisticItem item) {
    return Container(
      decoration: BoxDecoration(
        color: (item.color ?? Colors.indigo).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (item.color ?? Colors.indigo).withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color ?? Colors.indigo, size: 24),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: item.color ?? Colors.indigo,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatisticItem {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  _StatisticItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });
}
