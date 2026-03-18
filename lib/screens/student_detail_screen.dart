import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StudentProvider>();
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Header với Hero Animation
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'student-${student.id}',
                child: CachedNetworkImage(
                  imageUrl: student.avatarUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 2. Nội dung chi tiết
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('MSSV: ${student.mssv}', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      _buildGPABadge(student.gpa4),
                    ],
                  ),
                  const Divider(height: 40),
                  
                  // Thông tin cơ bản
                  _buildSectionTitle('Thông tin cơ bản'),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.school, 'Khoa', provider.getDepartmentName(student.classId)),
                  _buildInfoRow(Icons.book, 'Ngành', provider.getMajorName(student.classId)),
                  _buildInfoRow(Icons.group, 'Lớp học', provider.getClassName(student.classId)),
                  _buildInfoRow(Icons.location_on, 'Quê quán', student.hometown),
                  _buildInfoRow(Icons.phone, 'Số điện thoại', student.phoneNumber),

                  const Divider(height: 40),

                  // Bảng điểm (Thành viên C sẽ phát triển thêm biểu đồ ở đây)
                  _buildSectionTitle('Bảng điểm chi tiết'),
                  const SizedBox(height: 16),
                  if (student.grades.isEmpty)
                    const Text('Chưa có dữ liệu điểm môn học.')
                  else
                    ...student.grades.map((g) => _buildGradeItem(g.subjectId, g.score)),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // Action Buttons
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Chỉnh sửa hồ sơ', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.edit, color: Colors.white),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget _buildGPABadge(double gpa) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: gpa >= 3.2 ? Colors.green : Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('GPA 4.0', style: TextStyle(color: Colors.white70, fontSize: 10)),
          Text(gpa.toString(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo));
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: Colors.indigo),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradeItem(String subject, double score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(subject, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(score.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: score >= 5 ? Colors.green : Colors.red)),
        ],
      ),
    );
  }
}
