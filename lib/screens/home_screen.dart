import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/student_provider.dart';
import '../models/student.dart';
import 'student_detail_screen.dart';
import 'add_student_screen.dart';
import 'filter_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Đang tải dữ liệu học viện...",
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            toolbarHeight: 80,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thực hành 5 - G13',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Text(
                  'Student Manager',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3949AB), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FilterHistoryScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => provider.refreshStudents(),
              ),
            ],
          ),
          body: Column(
            children: [
              // 1. Analytics Cards
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _buildQuickStat(
                      'Tổng số',
                      provider.totalStudents.toString(),
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickStat(
                      'Xuất sắc',
                      provider.excellentStudents.toString(),
                      Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickStat(
                      'Yếu/Kém',
                      provider.warningStudents.toString(),
                      Colors.red,
                    ),
                  ],
                ),
              ),

              // 2. Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) => provider.setSearchQuery(v),
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm tên hoặc MSSV...',
                      prefixIcon: Icon(Icons.search, color: Colors.indigo),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),

              // 3. Dept Filter
              Container(
                height: 90,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.departments.length + 1,
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final dept = isAll ? null : provider.departments[index - 1];
                    final isSelected = isAll
                        ? provider.selectedDepartmentId == null
                        : provider.selectedDepartmentId == dept?.id;

                    return GestureDetector(
                      onTap: () =>
                          provider.selectDepartment(isAll ? null : dept?.id),
                      child: Container(
                        width: 75,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.indigo : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected
                                ? Colors.indigo
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              isAll
                                  ? FontAwesomeIcons.borderAll
                                  : _getIconData(dept!.icon),
                              size: 18,
                              color: isSelected ? Colors.white : Colors.indigo,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAll ? 'Tất cả' : dept!.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 4. Student List
              Expanded(
                child: provider.students.isEmpty
                    ? const Center(child: Text("Không có sinh viên nào"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.students.length,
                        itemBuilder: (context, index) {
                          return _buildModernStudentCard(
                            context,
                            provider.students[index],
                            provider,
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddStudentScreen(),
                ),
              );
            },
            label: const Text('Thêm SV', style: TextStyle(color: Colors.white)),
            icon: const Icon(Icons.add, color: Colors.white),
            backgroundColor: Colors.indigo,
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStudentCard(
    BuildContext context,
    Student student,
    StudentProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDetailScreen(student: student),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'avatar-${student.id}',
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: CachedNetworkImageProvider(
                    student.avatarUrl,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'MSSV: ${student.mssv}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      provider.getMajorName(student.classId),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    student.gpa4.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    student.classification,
                    style: const TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'laptop':
        return FontAwesomeIcons.laptop;
      case 'chart-line':
        return FontAwesomeIcons.chartLine;
      case 'language':
        return FontAwesomeIcons.language;
      case 'car':
        return FontAwesomeIcons.car;
      case 'hotel':
        return FontAwesomeIcons.hotel;
      case 'bolt':
        return FontAwesomeIcons.bolt;
      case 'palette':
        return FontAwesomeIcons.palette;
      default:
        return FontAwesomeIcons.graduationCap;
    }
  }
}
