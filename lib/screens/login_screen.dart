import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_textfield.dart';
import '../theme.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> showLoginModal(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (ctx) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: LoginModal(),
    ),
  );
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-open the login modal overlay on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showLoginModal(context);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.headerGradient),
        alignment: Alignment.center,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: LoginModal(),
        ),
      ),
    );
  }
}

class LoginModal extends ConsumerStatefulWidget {
  const LoginModal({super.key});

  @override
  ConsumerState<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends ConsumerState<LoginModal> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _showUsernameField = false;
  String _role = 'Customer';
  bool _isRegister = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authProvider.notifier);
    try {
      if (_isRegister) {
        await notifier.register(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _role == 'Admin' ? 'admin' : 'customer',
        );
      } else {
        // For login, allow email or username
        final loginField = _showUsernameField || _usernameController.text.isNotEmpty
            ? _usernameController.text.trim()
            : _emailController.text.trim();
        await notifier.login(
          loginField,
          _passwordController.text,
        );
      }
      if (mounted) Navigator.of(context).maybePop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: selected ? Colors.white : Colors.white24),
          ),
          alignment: Alignment.center,
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authProvider);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.headerGradient),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              color: const Color(0xFF120C26),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.content_cut, color: AppTheme.accent),
                            const SizedBox(width: 8),
                            Text('app.name'.tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('auth.welcome_back'.tr(), textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text('auth.subtitle'.tr(),
                            textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _tab('auth.sign_in'.tr(), !_isRegister, () => setState(() {
                              _isRegister = false;
                              _showUsernameField = false;
                            })),
                            const SizedBox(width: 8),
                            _tab('auth.sign_up'.tr(), _isRegister, () => setState(() => _isRegister = true)),
                          ],
                        ),
                        if (!_isRegister)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () => setState(() => _showUsernameField = !_showUsernameField),
                                  child: Text(
                                    _showUsernameField ? 'Login with email' : 'Login with username',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        if (_isRegister) ...[
                          CustomTextField(
                            controller: _nameController,
                            label: 'auth.full_name'.tr(),
                            prefixIcon: Icons.person_outline,
                            validator: (v) => v?.isEmpty == true ? 'Full name is required' : null,
                          ),
                        ],
                        if (_isRegister || _showUsernameField) 
                          CustomTextField(
                            controller: _usernameController,
                            label: 'auth.username'.tr(),
                            prefixIcon: Icons.account_circle_outlined,
                            validator: (v) => v?.isEmpty == true ? 'Username is required' : null,
                          ),
                        CustomTextField(
                          controller: _emailController,
                          label: 'auth.email'.tr(),
                          prefixIcon: Icons.email_outlined,
                          validator: (v) => v?.isEmpty == true ? 'Email không được rỗng' : null,
                        ),
                        if (_isRegister)
                          CustomTextField(
                            controller: _phoneController,
                            label: 'auth.phone'.tr(),
                            prefixIcon: Icons.phone_outlined,
                            validator: (v) => v?.isEmpty == true ? 'SĐT không được rỗng' : null,
                          ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            labelText: 'auth.password'.tr(),
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                              onPressed: () => setState(() => _hidePassword = !_hidePassword),
                            ),
                          ),
                          validator: (v) => (v?.length ?? 0) < 6 ? 'Mật khẩu >=6 ký tự' : null,
                        ),
                        if (_isRegister)
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _hidePassword,
                            decoration: InputDecoration(
                              labelText: 'auth.confirm_password'.tr(),
                              prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                            ),
                            validator: (v) => v != _passwordController.text ? 'Mật khẩu không khớp' : null,
                          ),
                        if (_isRegister) ...[
                          const SizedBox(height: 8),
DropdownButtonFormField<String>(
                            initialValue: _role,
                            items: [
                              DropdownMenuItem(value: 'Customer', child: Text('auth.customer'.tr())),
                              DropdownMenuItem(value: 'Admin', child: Text('auth.salon'.tr())),
                            ],
                            onChanged: (v) => setState(() => _role = v ?? 'Customer'),
                            decoration: InputDecoration(labelText: 'auth.role'.tr(), prefixIcon: const Icon(Icons.workspace_premium, color: Colors.black87)),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppTheme.buttonGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                              onPressed: _submit,
                              child: Text(_isRegister ? 'auth.submit_register'.tr() : 'auth.submit_login'.tr()),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() => _isRegister = !_isRegister),
                          child: Text(_isRegister ? 'auth.switch_to_login'.tr() : 'auth.switch_to_register'.tr(), style: const TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
