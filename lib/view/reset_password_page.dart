import 'package:flutter/material.dart';
import 'package:mobile/utils/theme_utils.dart';
import 'package:mobile/viewmodel/auth_viewmodel.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      await AuthViewModel.instance.resetPassword(
        email: widget.email,
        code: codeController.text.trim(),
        newPassword: newPasswordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      ThemeUtils.getLogoPath(context),
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Redefinir senha',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enviamos um código para ${widget.email}',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Código de 6 dígitos',
                      prefixIcon: const Icon(Icons.pin),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o código';
                      }
                      if (value.length != 6) {
                        return 'O código deve ter 6 dígitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: newPasswordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Nova senha',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => obscurePassword = !obscurePassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite a nova senha';
                      }
                      if (value.length < 8) return 'Mínimo 8 caracteres';
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return 'Pelo menos 1 letra maiúscula';
                      }
                      if (!value.contains(RegExp(r'[a-z]'))) {
                        return 'Pelo menos 1 letra minúscula';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Pelo menos 1 número';
                      }
                      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                        return 'Pelo menos 1 caractere especial';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Confirmar nova senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirme a senha';
                      }
                      if (value != newPasswordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                            )
                          : const Text('REDEFINIR SENHA'),
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
