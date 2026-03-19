import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mssvController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _hometownController = TextEditingController();
  final _birthdayController = TextEditingController();
  String? _selectedClassId;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm sinh viên mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Họ và tên', Icons.person, (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null),
              const SizedBox(height: 16),
              _buildTextField(_mssvController, 'Mã số sinh viên (MSSV)', Icons.badge, (v) => v!.isEmpty ? 'Vui lòng nhập MSSV' : null),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedClassId,
                decoration: const InputDecoration(
                  labelText: 'Lớp học',
                  prefixIcon: Icon(Icons.class_, color: Colors.indigo),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                items: provider.classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _selectedClassId = v),
                validator: (v) => v == null ? 'Vui lòng chọn lớp' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'Số điện thoại', Icons.phone, (v) => v!.length != 10 ? 'SĐT phải có 10 số' : null, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(_emailController, 'Email', Icons.email, (v) => !v!.contains('@') ? 'Email không hợp lệ' : null, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(_hometownController, 'Quê quán', Icons.map, (v) => v!.isEmpty ? 'Vui lòng nhập quê quán' : null),
              const SizedBox(height: 16),
              _buildTextField(_birthdayController, 'Ngày sinh (DD/MM/YYYY)', Icons.cake, (v) => v!.isEmpty ? 'Vui lòng nhập ngày sinh' : null),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newStudent = Student(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        mssv: _mssvController.text,
                        name: _nameController.text,
                        classId: _selectedClassId!,
                        hometown: _hometownController.text,
                        email: _emailController.text,
                        birthday: _birthdayController.text,
                        avatarUrl: 'https://i.pravatar.cc/150?u=${DateTime.now().millisecond}',
                        phoneNumber: _phoneController.text,
                        status: StudentStatus.studying,
                        grades: [], // Mới thêm thì chưa có điểm
                      );
                      
                      provider.addStudent(newStudent);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thêm sinh viên thành công!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                      );
                    }
                  },
                  child: const Text('LƯU SINH VIÊN', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String? Function(String?)? validator, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }
}
