import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class ThemesPage extends StatelessWidget {
  const ThemesPage({super.key});

  static const List<Map<String, dynamic>> _themes = [
    {
      'id': 'default',
      'name': 'Padrão',
      'description': 'O tema original do Cancha. Limpo e funcional.',
      'previewColors': [
        Color(0xFF4CAF50),
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
        Color(0xFFE94560),
      ],
      'tag': 'Premium',
      'tagColor': Color(0xFFE94560),
    },
    {
      'id': 'campo',
      'name': 'Campo Natural',
      'description': 'Inspirado no gramado. Verde intenso e terra.',
      'previewColors': [
        Color(0xFF2E7D32),
        Color(0xFF1B5E20),
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
        Color(0xFF0D47A1),
        Color(0xFF1565C0),
        Color(0xFF82B1FF),
      ],
      'tag': 'Premium',
      'tagColor': Color(0xFF2979FF),
    },
    {
      'id': 'sunset',
      'name': 'Pôr do Sol',
      'description': 'Tons quentes de laranja e vermelho. Energia máxima.',
      'previewColors': [
        Color(0xFFBF360C),
        Color(0xFFE64A19),
        Color(0xFFFFD54F),
      ],
      'tag': 'Premium',
      'tagColor': Color(0xFFFF6D00),
    },
  ];

  void _applyTheme(BuildContext context, Map<String, dynamic> theme) {
    final provider = context.read<ThemeProvider>();
    provider.setTheme(theme['id'] as String);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tema "${theme['name']}" aplicado!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeId = context.watch<ThemeProvider>().currentThemeId;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Temas'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE0E0E0), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Personalize sua experiência',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Escolha o tema que combina com você.',
            style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 24),
          ..._themes.map(
            (theme) => _ThemeCard(
              theme: theme,
              isSelected: currentThemeId == theme['id'],
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
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme['previewColors'] as List<Color>;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (theme['tagColor'] as Color).withOpacity(
                              0.12,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            theme['tag'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme['tagColor'] as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme['description'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 26,
                )
              else
                const Icon(
                  Icons.radio_button_unchecked,
                  color: Color(0xFFBDBDBD),
                  size: 26,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
