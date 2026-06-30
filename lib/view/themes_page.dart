import 'package:flutter/material.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:mobile/view/premium_upgrade_page.dart';
import 'package:mobile/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class ThemesPage extends StatefulWidget {
  const ThemesPage({super.key});

  @override
  State<ThemesPage> createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage> {
  static const List<Map<String, dynamic>> _themes = [
    {
      'id': 'default',
      'name': 'Padrão',
      'description': 'O tema original do Cancha. Limpo e funcional.',
      'previewColors': [
        Color(0xFF2E7D32),
        Color(0xFFFFFFFF),
        Color(0xFFF5F5F5),
      ],
      'tag': 'Grátis',
      'tagColor': Color(0xFF4CAF50),
    },
    {
      'id': 'midnight',
      'name': 'Meia-Noite',
      'description': 'Modo escuro elegante. Ideal para jogar à noite.',
      'previewColors': [
        Color(0xFF1A1A2E),
        Color(0xFF16213E),
        Color(0xFFFF8A80),
      ],
      'tag': 'Premium',
      'tagColor': Color(0xFFE94560),
    },
    {
      'id': 'campo',
      'name': 'Campo Natural',
      'description': 'Inspirado no gramado. Verde intenso e terra.',
      'previewColors': [
        Color(0xFF66BB6A),
        Color(0xFF17461B),
        Color(0xFFFFC107),
      ],
      'tag': 'Premium',
      'tagColor': Color(0xFFFF8F00),
    },
    {
      'id': 'arena',
      'name': 'Arena',
      'description': 'Azul vibrante para quem joga com estilo.',
      'previewColors': [
        Color(0xFF82B1FF),
        Color(0xFF0B2F6B),
        Color(0xFF40C4FF),
      ],
      'tag': 'Premium',
      'tagColor': Color(0xFF2979FF),
    },
    {
      'id': 'sunset',
      'name': 'Pôr do Sol',
      'description': 'Tons quentes de laranja e vermelho. Energia máxima.',
      'previewColors': [
        Color(0xFFFFB74D),
        Color(0xFF5E250D),
        Color(0xFFFFD54F),
      ],
      'tag': 'Premium',
      'tagColor': Color(0xFFFF6D00),
    },
  ];

  Future<void> _applyTheme(
    BuildContext context,
    Map<String, dynamic> theme,
  ) async {
    final user = AuthViewModel.instance.currentUser;
    if (user == null) return;

    final themeId = theme['id'] as String;
    final isPremiumTheme = AppThemes.isPremiumTheme(themeId);

    if (isPremiumTheme && !user.isPremium) {
      _showPremiumRequiredDialog(context);
      return;
    }

    final provider = context.read<ThemeProvider>();
    final applied = await provider.setTheme(
      themeId,
      userId: user.id,
      isPremium: user.isPremium,
    );
    if (!context.mounted) return;
    if (!applied) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tema "${theme['name']}" aplicado!',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPremiumRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🎨 Tema Premium'),
        content: const Text(
          'Este tema é exclusivo para assinantes Premium.\n'
          'Deseja se tornar Premium agora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Agora não'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumUpgradePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Tornar-se Premium'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeId = context.watch<ThemeProvider>().currentThemeId;
    final isUserPremium =
        AuthViewModel.instance.currentUser?.isPremium ?? false;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Temas'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Personalize sua experiência',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Escolha o tema que combina com você.',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          ..._themes.map(
            (theme) => _ThemeCard(
              theme: theme,
              isSelected: currentThemeId == theme['id'],
              isUserPremium: isUserPremium,
              onTap: () => _applyTheme(context, theme),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final Map<String, dynamic> theme;
  final bool isSelected;
  final bool isUserPremium;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.isUserPremium,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme['previewColors'] as List<Color>;
    final isPremiumTheme = AppThemes.isPremiumTheme(theme['id'] as String);
    final canSelect = !isPremiumTheme || isUserPremium;
    final colorScheme = Theme.of(context).colorScheme;
    final tagColor = theme['tagColor'] as Color;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: canSelect ? 1.0 : 0.6,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withValues(alpha: 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: Column(
                          children: [
                            Expanded(child: Container(color: colors[0])),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(child: Container(color: colors[1])),
                                  Expanded(child: Container(color: colors[2])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                theme['name'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: tagColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  theme['tag'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            theme['description'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                        size: 26,
                      )
                    else
                      Icon(
                        Icons.radio_button_unchecked,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        size: 26,
                      ),
                  ],
                ),
              ),
            ),
            if (!canSelect)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
