import 'package:flutter/material.dart';
import 'package:mobile/model/user.dart';
import 'package:mobile/viewmodel/auth_viewmodel.dart';
import 'package:mobile/view/login_page.dart';
import 'package:mobile/services/api_client.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final User? user;

  @override
  void initState() {
    super.initState();
    user = AuthViewModel.instance.currentUser;
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Alterar senha'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha atual',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Digite a senha atual' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova senha',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Digite a nova senha';
                  if (v.length < 8) return 'Mínimo 8 caracteres';
                  if (!v.contains(RegExp(r'[A-Z]')))
                    return 'Uma letra maiúscula';
                  if (!v.contains(RegExp(r'[a-z]')))
                    return 'Uma letra minúscula';
                  if (!v.contains(RegExp(r'[0-9]'))) return 'Um número';
                  if (!v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')))
                    return 'Um caractere especial';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nova senha',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v != newPasswordController.text
                    ? 'As senhas não coincidem'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext);
                try {
                  await ApiClient().post('/auth/change-password', {
                    'currentPassword': currentPasswordController.text,
                    'newPassword': newPasswordController.text,
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Senha alterada com sucesso!'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Alterar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: user!.photo != null && user!.photo!.isNotEmpty
                  ? NetworkImage(user!.photo!)
                  : const AssetImage('assets/images/default_perfil.jpg')
                        as ImageProvider,
              child: user!.photo == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 24),
            Text(
              user!.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(user!.email, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(user!.phone, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await AuthViewModel.instance.logout();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              },
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Sair'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showChangePasswordDialog(context),
              icon: const Icon(Icons.lock_reset),
              label: const Text('Alterar Senha'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
