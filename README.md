# Cancha Mobile

Aplicativo Flutter para descoberta de estabelecimentos esportivos, consulta de quadras e gerenciamento de reservas. O app centraliza a jornada do jogador: criar conta, encontrar locais, consultar horários disponíveis, confirmar reservas e acompanhar seus agendamentos.

## Funcionalidades

- Autenticação de usuários com login, cadastro, recuperação e redefinição de senha.
- Listagem de estabelecimentos esportivos com localização e imagem.
- Consulta de quadras por estabelecimento, modalidade e detalhes da quadra.
- Visualização de horários de funcionamento, preços e disponibilidade.
- Criação e cancelamento de reservas.
- Tela de calendário com reservas do usuário.
- Integração com mapa para visualizar a localização do estabelecimento.
- Perfil do usuário com gerenciamento de conta e assinatura Premium.
- Temas personalizáveis, incluindo temas exclusivos para usuários Premium.
- Splash screen nativa e ícones configurados para Android e iOS.
- Tela Wearable para experiência simplificada em dispositivo vestível.

## Tecnologias

- Flutter
- Dart
- Provider para gerenciamento de estado
- HTTP para comunicação com API
- Shared Preferences para persistência local
- Flutter Map, LatLong2 e Geolocator para mapa e localização
- Flutter Native Splash para splash screen nativa
- Flutter Launcher Icons para geração dos ícones do app

## Estrutura do Projeto

```text
lib/
  config/       Configurações globais, incluindo URL da API
  model/        Modelos de domínio
  services/     Cliente HTTP e integrações
  theme/        Temas e provider de tema
  utils/        Utilitários compartilhados
  view/         Telas do aplicativo
  viewmodel/    Regras de apresentação e comunicação com serviços
```

## Requisitos

- Flutter SDK compatível com Dart `^3.11.1`
- Android Studio ou Xcode para builds nativos
- API backend disponível em:
  - Web: `http://localhost:3000`
  - Android emulator: `http://10.0.2.2:3000`

## Como Rodar

```bash
flutter pub get
flutter run
```

Para validar o projeto:

```bash
flutter analyze
```

## Splash Screen e Ícones

A splash screen é configurada via `flutter_native_splash` no `pubspec.yaml`.

Para regenerar:

```bash
dart run flutter_native_splash:create
```

Os ícones do app são configurados via `flutter_launcher_icons`, usando `assets/images/cancha_apk.png`.

Para regenerar:

```bash
dart run flutter_launcher_icons
```

## Assets Principais

- `assets/images/cancha_logo.png`: logo principal.
- `assets/images/cancha_dark_logo.png`: logo para splash/tema escuro.
- `assets/images/cancha_apk.png`: ícone do aplicativo.
- `assets/images/default_*.jpg`: imagens padrão por modalidade.
- `assets/images/default_perfil.jpg`: imagem padrão de perfil.

## Observações de Desenvolvimento

- A URL da API está em `lib/config/api_config.dart`.
- A seleção de tema é persistida localmente com `shared_preferences`.
- Temas Premium exigem usuário com assinatura ativa.
- Antes de abrir pull request, rode `flutter analyze` e revise alterações em assets nativos gerados.
