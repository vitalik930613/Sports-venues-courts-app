import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Termos de Uso e Privacidade', 
          style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ 
            const Text(
             'Termos de uso', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('''
1. ACEITAÇÃO DOS TERMOS

Ao baixar, acessar ou utilizar este aplicativo, o usuário concorda com os presentes Termos de Uso. Caso não concorde com qualquer disposição destes termos, deverá interromper o uso do aplicativo.

2. USO DO APLICATIVO

O aplicativo é disponibilizado para uso pessoal e não comercial, salvo autorização expressa dos desenvolvedores.

O usuário compromete-se a utilizar o aplicativo de forma legal, ética e em conformidade com a legislação vigente.

3. CADASTRO E CONTA

Algumas funcionalidades podem exigir a criação de uma conta.

O usuário é responsável por:

• Fornecer informações verdadeiras e atualizadas;
• Manter a confidencialidade de sua senha;
• Comunicar imediatamente qualquer uso não autorizado de sua conta.

4. CONDUTAS PROIBIDAS

É proibido:

• Utilizar o aplicativo para atividades ilícitas;
• Tentar acessar áreas restritas do sistema sem autorização;
• Inserir vírus, códigos maliciosos ou qualquer conteúdo que possa prejudicar o funcionamento do aplicativo;
• Violar direitos de terceiros.

5. PROPRIEDADE INTELECTUAL

Todo o conteúdo do aplicativo, incluindo textos, imagens, logotipos, códigos e funcionalidades, é protegido pela legislação de propriedade intelectual e pertence aos seus respectivos titulares.

6. LIMITAÇÃO DE RESPONSABILIDADE

O aplicativo é fornecido "como está", sem garantias de disponibilidade contínua ou ausência de falhas.

Os desenvolvedores não serão responsáveis por:

• Perdas decorrentes de indisponibilidade do serviço;
• Danos causados por uso indevido do aplicativo;
• Informações inseridas pelos próprios usuários.

7. ALTERAÇÕES DOS TERMOS

Os Termos de Uso poderão ser modificados a qualquer momento. A continuidade do uso do aplicativo após a publicação das alterações será considerada como aceitação dos novos termos.

8. ENCERRAMENTO DA CONTA

Os desenvolvedores poderão suspender ou encerrar contas que violem estes Termos de Uso.
''', style: TextStyle(fontSize: 16, height: 1.5),
 ),
 const SizedBox(height: 32),
 const Text('Política de Privacidade',
 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
 ),

 const SizedBox(height: 16),
 const Text(
  '''
1. INFORMAÇÕES COLETADAS

O aplicativo poderá coletar:

• Nome;
• E-mail;
• Telefone;
• Informações fornecidas durante o uso do aplicativo;
• Dados técnicos do dispositivo, como sistema operacional e versão do aplicativo.

2. FINALIDADE DA COLETA

Os dados poderão ser utilizados para:

• Criar e gerenciar contas de usuários;
• Fornecer funcionalidades do aplicativo;
• Melhorar a experiência de uso;
• Garantir a segurança da plataforma;
• Entrar em contato quando necessário.

3. COMPARTILHAMENTO DE DADOS

Os dados não serão vendidos a terceiros.

O compartilhamento poderá ocorrer apenas:

• Mediante consentimento do usuário;
• Para cumprimento de obrigações legais;
• Quando necessário para prestação dos serviços.

4. ARMAZENAMENTO E SEGURANÇA

São adotadas medidas razoáveis de segurança para proteger os dados contra acesso não autorizado, alteração, divulgação ou destruição.

5. DIREITOS DO USUÁRIO

O usuário poderá solicitar:

• Acesso aos seus dados;
• Correção de informações incorretas;
• Exclusão de sua conta;
• Exclusão dos dados pessoais armazenados, quando aplicável.

6. COOKIES E TECNOLOGIAS SEMELHANTES

Caso o aplicativo utilize cookies ou tecnologias equivalentes, eles serão empregados para melhorar a experiência do usuário e coletar informações de uso.

7. ALTERAÇÕES NESTA POLÍTICA

Esta Política de Privacidade poderá ser atualizada periodicamente. As alterações entrarão em vigor após sua publicação no aplicativo.

8. CONTATO

Para dúvidas relacionadas aos Termos de Uso ou à Política de Privacidade, entre em contato através do e-mail:

cancha@gmail.com
''', 
style: TextStyle(fontSize: 16, height: 1.5),
          )
        ],
      ),
    ),
  );
 }
}
