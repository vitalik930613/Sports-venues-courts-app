import 'package:flutter/material.dart';
import 'package:mobile/model/user.dart';
import 'package:mobile/theme/theme_provider.dart';
import 'package:mobile/view/premium_upgrade_page.dart';
import 'package:mobile/viewmodel/auth_viewmodel.dart';
import 'package:mobile/view/login_page.dart';
import 'package:mobile/view/change_password_page.dart';
import 'package:mobile/view/themes_page.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User? user;
  final TextEditingController _deleteConfirmController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    user = AuthViewModel.instance.currentUser;
  }

  @override
  void dispose() {
    _deleteConfirmController.dispose();
    super.dispose();
  }

  void _refreshUser() {
    setState(() {
      user = AuthViewModel.instance.currentUser;
    });
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Excluir Conta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta ação é PERMANENTE e não pode ser desfeita.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Todos os seus dados serão removidos.'),
            const SizedBox(height: 20),
            const Text(
              'Digite "DELETE" no campo abaixo para confirmar:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _deleteConfirmController,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'DELETE',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_deleteConfirmController.text.trim().toUpperCase() ==
                  'DELETE') {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Digite "DELETE" para confirmar'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _deleteConfirmController.clear());
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await AuthViewModel.instance.deleteAccount();
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta excluída com sucesso.')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        String errorMsg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _cancelPremium() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar assinatura Premium'),
        content: const Text(
          'Tem certeza que deseja cancelar sua assinatura? Você perderá todos os benefícios exclusivos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await AuthViewModel.instance.cancelPremium();
      final themeProvider = context.read<ThemeProvider>();
      themeProvider.setTheme('default');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Assinatura cancelada. Você agora é um usuário gratuito.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        _refreshUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildButtonRow(Widget leftButton, Widget rightButton) {
    return Row(
      children: [
        Expanded(child: leftButton),
        const SizedBox(width: 16),
        Expanded(child: rightButton),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final primary = Theme.of(context).colorScheme.primary;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final isUserPremium = user?.isPremium ?? false;

    final sideButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );

    final changePasswordButton = ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
        );
      },
      icon: const Icon(Icons.lock_reset),
      label: const Text('Alterar Senha'),
      style: sideButtonStyle.copyWith(
        backgroundColor: MaterialStatePropertyAll(primary),
      ),
    );

    final themesButton = ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ThemesPage()),
        );
      },
      icon: const Icon(Icons.palette_outlined),
      label: const Text('Temas'),
      style: sideButtonStyle.copyWith(
        backgroundColor: const MaterialStatePropertyAll(Color(0xFF7B1FA2)),
      ),
    );

    final deleteAccountButton = ElevatedButton.icon(
      onPressed: _confirmDeleteAccount,
      icon: const Icon(Icons.delete_forever),
      label: const Text('Deletar Conta'),
      style: sideButtonStyle.copyWith(
        backgroundColor: const MaterialStatePropertyAll(Colors.red),
      ),
    );

    final logoutButton = ElevatedButton.icon(
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
      style: sideButtonStyle.copyWith(
        backgroundColor: const MaterialStatePropertyAll(Colors.grey),
      ),
    );

    final premiumButton = isUserPremium
        ? ElevatedButton.icon(
            onPressed: _isLoading ? null : _cancelPremium,
            icon: const Icon(Icons.star_border),
            label: const Text('Cancelar Assinatura Premium'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        : ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumUpgradePage()),
              ).then((_) => _refreshUser());
            },
            icon: const Icon(Icons.star),
            label: const Text('Tornar-se Premium'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(title: const Text('Meu Perfil'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset('assets/images/cancha_logo.png', height: 80),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: user!.photo != null && user!.photo!.isNotEmpty
                  ? NetworkImage(user!.photo!)
                  : const AssetImage('assets/images/default_perfil.jpg')
                        as ImageProvider,
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
            _buildButtonRow(changePasswordButton, themesButton),
            const SizedBox(height: 16),
            _buildButtonRow(deleteAccountButton, logoutButton),
            const SizedBox(height: 16),
            premiumButton,
          ],
        ),
      ),
    );
  }
}
