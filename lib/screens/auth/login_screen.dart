import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isRegister = false;
  bool _isLoading = false;
  String _email = '';
  String _password = '';
  String _displayName = '';
  String _role = 'user'; // 'user' hoặc 'admin'
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isRegister) {
        await _authService.register(
          email: _email,
          password: _password,
          displayName: _displayName.isNotEmpty ? _displayName : _email.split('@').first,
          role: _role,
        );
      } else {
        await _authService.login(email: _email, password: _password);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains(']')
            ? e.toString().split(']').last.trim()
            : e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.coffee_rounded, size: 68, color: AppColors.primary),
                  const SizedBox(height: 12),
                  const Text(
                    'ECOMER',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Text(
                    'Cà phê ngon hơn mỗi ngày',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    _isRegister ? 'Tạo tài khoản mới' : 'Đăng nhập',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                      ),
                    ),

                  if (_isRegister) ...[
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Họ và tên',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập họ tên' : null,
                      onSaved: (val) => _displayName = val ?? '',
                    ),
                    const SizedBox(height: 14),
                  ],

                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (val) =>
                        val == null || !val.contains('@') ? 'Email không hợp lệ' : null,
                    onSaved: (val) => _email = val ?? '',
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (val) =>
                        val == null || val.length < 6 ? 'Mật khẩu tối thiểu 6 ký tự' : null,
                    onSaved: (val) => _password = val ?? '',
                  ),
                  const SizedBox(height: 14),

                  if (_isRegister) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _role,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'user',
                              child: Row(
                                children: [
                                  Icon(Icons.person, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Khách hàng (User)'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Row(
                                children: [
                                  Icon(Icons.admin_panel_settings, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('Quản trị viên (Admin)'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) => setState(() => _role = val ?? 'user'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _isRegister ? 'Đăng ký tài khoản' : 'Đăng nhập',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => setState(() {
                      _isRegister = !_isRegister;
                      _errorMessage = null;
                    }),
                    child: Text(
                      _isRegister
                          ? 'Đã có tài khoản? Đăng nhập ngay'
                          : 'Chưa có tài khoản? Đăng ký tại đây',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
