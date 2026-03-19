import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/student.dart';
import '../models/academic_models.dart';
import '../providers/student_provider.dart';
import 'package:provider/provider.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        // Tìm lại sinh viên từ provider để cập nhật UI khi có thay đổi từ BottomSheet
        final currentStudent = provider.students.firstWhere((s) => s.id == student.id, orElse: () => student);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết sinh viên', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3949AB), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile Header (Hero Animation)
                _buildProfileHeader(currentStudent, provider),
                const SizedBox(height: 24),

                // 2. Information Section (Hồ sơ 360)
                _buildSectionTitle('Thông tin cá nhân'),
                const SizedBox(height: 12),
                _buildInfoCard([
                  _buildInfoRow(Icons.cake, 'Ngày sinh', currentStudent.birthday),
                  _buildInfoRow(Icons.email, 'Email', currentStudent.email),
                  _buildInfoRow(Icons.location_on, 'Quê quán', currentStudent.hometown),
                  _buildInfoRow(Icons.phone, 'Số điện thoại', currentStudent.phoneNumber),
                  _buildInfoRow(Icons.school, 'Lớp', provider.getClassName(currentStudent.classId)),
                ]),
                const SizedBox(height: 24),

                // 3. Academic Section (Bảng điểm & GPA)
                _buildSectionTitle('Kết quả học tập'),
                const SizedBox(height: 12),
                _buildAcademicCard(currentStudent),
                const SizedBox(height: 24),

                // 4. Analytics Section (Chart)
                _buildSectionTitle('Biểu đồ điểm số'),
                const SizedBox(height: 12),
                _buildChartCard(currentStudent),
                const SizedBox(height: 24),

                // 5. Action Buttons (Chỉ giữ lại nút Chỉnh sửa)
                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showEditBottomSheet(context, currentStudent, provider),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Chỉnh sửa hồ sơ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(Student student, StudentProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'avatar-${student.id}',
            child: CircleAvatar(
              radius: 45,
              backgroundImage: CachedNetworkImageProvider(student.avatarUrl),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('MSSV: ${student.mssv}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 10),
                _buildTag(student.classification),
              ],
            ),
          ),
          Column(
            children: [
              Text(student.gpa4.toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const Text('GPA (4.0)', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicCard(Student student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGradeStat('GPA Hệ 10', student.gpa10.toString(), Colors.blue),
              _buildGradeStat('GPA Hệ 4', student.gpa4.toString(), Colors.indigo),
              _buildGradeStat('Tín chỉ', student.grades.fold(0, (sum, g) => sum + g.credits).toString(), Colors.orange),
            ],
          ),
          const Divider(height: 32),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: student.grades.length,
            itemBuilder: (context, index) {
              final grade = student.grades[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(grade.subjectId, style: const TextStyle(fontWeight: FontWeight.w500))),
                    Text('${grade.credits} TC', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 20),
                    Text(grade.score.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGradeStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildChartCard(Student student) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: BarChart(
        BarChartData(
          maxY: 10,
          barGroups: student.grades.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.score, color: Colors.indigo, width: 15)])).toList(),
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context, Student student, StudentProvider provider) {
    final nameController = TextEditingController(text: student.name);
    final phoneController = TextEditingController(text: student.phoneNumber);
    final emailController = TextEditingController(text: student.email);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chỉnh sửa thông tin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Họ tên', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder()),
                validator: (v) => v!.length != 10 ? 'Phải đủ 10 số' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (v) => !v!.contains('@') ? 'Email không hợp lệ' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: const EdgeInsets.all(15)),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final updated = student.copyWith(
                        name: nameController.text,
                        phoneNumber: phoneController.text,
                        email: emailController.text,
                      );
                      provider.updateStudent(updated);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
                    }
                  },
                  child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo));
  Widget _buildInfoCard(List<Widget> children) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)), child: Column(children: children));
  Widget _buildInfoRow(IconData icon, String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Icon(icon, size: 18, color: Colors.indigo), const SizedBox(width: 15), Text(label, style: const TextStyle(color: Colors.grey)), const Spacer(), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]));
  Widget _buildTag(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo)));
}
