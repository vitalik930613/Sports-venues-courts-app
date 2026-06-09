import 'package:flutter/material.dart';
 
class ThemesPage extends StatefulWidget {
  const ThemesPage({super.key});
 
  @override
  State<ThemesPage> createState() => _ThemesPageState();
}
 
class _ThemesPageState extends State<ThemesPage> {
  String _selectedTheme = 'default'; 
 
  final List<Map<String, dynamic>> _themes = [
    {
      'id': 'default',
      'name': 'Padrão',
      'description': 'O tema original do Cancha. Limpo e funcional.',
      'isPaid': false,
      'price': null,
      'primaryColor': Color(0xFF4CAF50),
      'secondaryColor': Color(0xFFFFFFFF),
      'accentColor': Color(0xFF388E3C),
      'previewColors': [Color(0xFF4CAF50), Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
      'tag': 'Grátis',
      'tagColor': Color(0xFF4CAF50),
    },
    {
      'id': 'midnight',
      'name': 'Meia-Noite',
      'description': 'Modo escuro elegante. Ideal para jogar à noite.',
      'isPaid': true,
      'price': 'R\$ 4,99/mês',
      'primaryColor': Color(0xFF1A1A2E),
      'secondaryColor': Color(0xFF16213E),
      'accentColor': Color(0xFF0F3460),
      'previewColors': [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFFE94560)],
      'tag': 'Premium',
      'tagColor': Color(0xFFE94560),
    },
    {
      'id': 'campo',
      'name': 'Campo Natural',
      'description': 'Inspirado no gramado. Verde intenso e terra.',
      'isPaid': true,
      'price': 'R\$ 4,99/mês',
      'primaryColor': Color(0xFF2E7D32),
      'secondaryColor': Color(0xFF1B5E20),
      'accentColor': Color(0xFFFFC107),
      'previewColors': [Color(0xFF2E7D32), Color(0xFF1B5E20), Color(0xFFFFC107)],
      'tag': 'Premium',
      'tagColor': Color(0xFFFF8F00),
    },
    {
      'id': 'arena',
      'name': 'Arena',
      'description': 'Azul vibrante para quem joga com estilo.',
      'isPaid': true,
      'price': 'R\$ 4,99/mês',
      'primaryColor': Color(0xFF0D47A1),
      'secondaryColor': Color(0xFF1565C0),
      'accentColor': Color(0xFF82B1FF),
      'previewColors': [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF82B1FF)],
      'tag': 'Premium',
      'tagColor': Color(0xFF2979FF),
    },
    {
      'id': 'sunset',
      'name': 'Pôr do Sol',
      'description': 'Tons quentes de laranja e vermelho. Energia máxima.',
      'isPaid': true,
      'price': 'R\$ 4,99/mês',
      'primaryColor': Color(0xFFBF360C),
      'secondaryColor': Color(0xFFE64A19),
      'accentColor': Color(0xFFFFD54F),
      'previewColors': [Color(0xFFBF360C), Color(0xFFE64A19), Color(0xFFFFD54F)],
      'tag': 'Premium',
      'tagColor': Color(0xFFFF6D00),
    },
  ];
 
  void _onThemeSelect(Map<String, dynamic> theme) {
    if (theme['isPaid'] as bool) {
      _showPaymentDialog(theme);
    } else {
      setState(() => _selectedTheme = theme['id'] as String);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tema "${theme['name']}" aplicado!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
 
  void _showPaymentDialog(Map<String, dynamic> theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentSheet(theme: theme),
    );
  }
 
  @override
  Widget build(BuildContext context) {
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
          ..._themes.map((theme) => _ThemeCard(
                theme: theme,
                isSelected: _selectedTheme == theme['id'],
                onTap: () => _onThemeSelect(theme),
              )),
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
    final isPaid = theme['isPaid'] as bool;
 
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
              // Preview de cores
              Column(
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
                ],
              ),
              const SizedBox(width: 16),
 
              // Info
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
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (theme['tagColor'] as Color).withOpacity(0.12),
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
                    if (isPaid) ...[
                      const SizedBox(height: 6),
                      Text(
                        theme['price'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
 
              // Indicador selecionado / botão
              const SizedBox(width: 8),
              if (isSelected)
                const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 26)
              else if (isPaid)
                const Icon(Icons.lock_outline, color: Color(0xFFBDBDBD), size: 22)
              else
                const Icon(Icons.radio_button_unchecked,
                    color: Color(0xFFBDBDBD), size: 26),
            ],
          ),
        ),
      ),
    );
  }
}
 
 
class _PaymentSheet extends StatelessWidget {
  final Map<String, dynamic> theme;
 
  const _PaymentSheet({required this.theme});
 
  @override
  Widget build(BuildContext context) {
    final colors = theme['previewColors'] as List<Color>;
 
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
 
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: Row(
                children: [
                  Expanded(flex: 2, child: Container(color: colors[0])),
                  Expanded(
                    child: Column(
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
          const SizedBox(height: 20),
 
          Text(
            theme['name'] as String,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            theme['description'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 28),
 
          _BenefitRow(icon: Icons.palette_outlined, label: 'Tema exclusivo aplicado em todo o app'),
          const SizedBox(height: 10),
          _BenefitRow(icon: Icons.update, label: 'Acesso imediato após a confirmação'),
          const SizedBox(height: 10),
          _BenefitRow(icon: Icons.cancel_outlined, label: 'Cancele quando quiser'),
          const SizedBox(height: 28),
 
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade de pagamento em breve!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Assinar por ${theme['price']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Agora não',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
 
class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String label;
 
  const _BenefitRow({required this.icon, required this.label});
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
          ),
        ),
      ],
    );
  }
}