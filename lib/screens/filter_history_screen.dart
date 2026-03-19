import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../models/student.dart';

class FilterHistoryScreen extends StatefulWidget {
  const FilterHistoryScreen({super.key});

  @override
  State<FilterHistoryScreen> createState() => _FilterHistoryScreenState();
}

class _FilterHistoryScreenState extends State<FilterHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? _selectedDepartmentId;
  String _selectedClassification = 'Tất cả';
  double _minGpa = 0.0; // gpa4

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Student> _applyFilters(
    List<Student> list,
    int tabIndex,
    StudentProvider provider,
  ) {
    Iterable<Student> filtered = list;

    // tab filter by status
    switch (tabIndex) {
      case 0:
        filtered = filtered.where((s) => s.status == StudentStatus.pending);
        break;
      case 1:
        filtered = filtered.where((s) => s.status == StudentStatus.studying);
        break;
      case 2:
        filtered = filtered.where((s) => s.status == StudentStatus.suspended);
        break;
      case 3:
        filtered = filtered.where((s) => s.status == StudentStatus.deleted);
        break;
    }

    if (_selectedDepartmentId != null) {
      filtered = filtered.where((s) {
        try {
          final classInfo = provider.classes.firstWhere(
            (c) => c.id == s.classId,
          );
          final major = provider.departments.isNotEmpty
              ? provider.departments.firstWhere(
                  (d) => d.id == provider.departments.first.id,
                  orElse: () => provider.departments.first,
                )
              : null;
          // fallback: compare by department id via provider.getDepartmentName
          return provider.getDepartmentName(s.classId) ==
              provider.departments
                  .firstWhere((d) => d.id == _selectedDepartmentId)
                  .name;
        } catch (e) {
          return false;
        }
      });
    }

    if (_selectedClassification != 'Tất cả') {
      filtered = filtered.where(
        (s) => s.classification == _selectedClassification,
      );
    }

    if (_minGpa > 0) {
      filtered = filtered.where((s) => s.gpa4 >= _minGpa);
    }

    return filtered.toList();
  }

  void _exportReport() async {
    // Simulate export
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xuất báo cáo'),
        content: const Text('Đã xuất báo cáo thành công! (mô phỏng)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        final depts = provider.departments;
        final classifications = [
          'Tất cả',
          'Xuất sắc',
          'Giỏi',
          'Khá',
          'Trung bình',
          'Yêu/Kém',
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Bộ lọc & Lịch sử',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Chờ duyệt'),
                Tab(text: 'Đang học'),
                Tab(text: 'Bảo lưu'),
                Tab(text: 'Đã xóa'),
              ],
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3949AB), Color(0xFF1E88E5)],
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _exportReport,
                icon: const Icon(Icons.file_download),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDepartmentId,
                        decoration: const InputDecoration(
                          labelText: 'Khoa',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Tất cả'),
                          ),
                          ...depts.map(
                            (d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(d.name),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedDepartmentId = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedClassification,
                        decoration: const InputDecoration(
                          labelText: 'Xếp loại',
                          border: OutlineInputBorder(),
                        ),
                        items: classifications
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (v) => setState(
                          () => _selectedClassification = v ?? 'Tất cả',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    const Text('GPA tối thiểu:'),
                    Expanded(
                      child: Slider(
                        min: 0.0,
                        max: 4.0,
                        divisions: 8,
                        value: _minGpa,
                        label: _minGpa == 0
                            ? 'Không'
                            : _minGpa.toStringAsFixed(1),
                        onChanged: (v) => setState(() => _minGpa = v),
                      ),
                    ),
                    Text(_minGpa == 0 ? 'Không' : _minGpa.toStringAsFixed(1)),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(4, (i) {
                    final list = _applyFilters(provider.students, i, provider);
                    if (list.isEmpty)
                      return const Center(
                        child: Text('Không có sinh viên phù hợp'),
                      );
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: list.length,
                      itemBuilder: (context, idx) {
                        final s = list[idx];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(s.avatarUrl),
                            ),
                            title: Text(s.name),
                            subtitle: Text(
                              '${s.mssv} • ${provider.getClassName(s.classId)} • ${provider.getDepartmentName(s.classId)}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  s.gpa4.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  s.classification,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
