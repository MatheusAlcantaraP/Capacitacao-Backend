# AsiCity 🏙️

AsiCity é um aplicativo para reportar problemas urbanos, como buracos na via pública ou falhas de iluminação. O projeto foi desenvolvido como desafio da Semana 6-7 da capacitação Asimov Jr, simulando uma solução que uma prefeitura poderia adotar para acompanhar as demandas dos moradores em tempo real.

## Visão geral

O acesso ao aplicativo exige cadastro e login, garantindo que cada reporte tenha um autor identificado. Uma vez autenticado, o usuário tem acesso a um feed com todos os reportes da cidade, atualizado automaticamente conforme novos registros são criados.

Para reportar um problema, o usuário preenche um formulário com título e descrição, captura uma foto pela câmera do dispositivo e tem sua localização registrada automaticamente via GPS, com uma prévia exibida em mapa antes da confirmação.

Cada reporte pode ser curtido, comentado e marcado como "ainda persistente" por outros usuários, com atualizações refletidas em tempo real para todos que estiverem visualizando a mesma tela. O aplicativo conta ainda com um chat da comunidade, permitindo que os usuários discutam livremente sobre os problemas do bairro, e envia notificações push ao autor de um reporte sempre que houver uma nova interação.

## Funcionalidades

- Autenticação de usuários com e-mail e senha
- Criação de reportes com foto, localização e descrição
- Feed de reportes atualizado em tempo real
- Curtidas, comentários e marcação de persistência do problema
- Chat da comunidade em tempo real
- Notificações push para o autor do reporte

## Tecnologias

O aplicativo foi desenvolvido em Flutter, com o Firebase como principal camada de backend:

- **Firebase Authentication** — cadastro, login e controle de sessão
- **Cloud Firestore** — persistência de reportes, comentários e mensagens, com sincronização em tempo real via Streams
- **Firebase Storage** — armazenamento das fotos enviadas pelos usuários
- **Firebase Cloud Messaging** — envio de notificações push
- **Google Maps SDK** — exibição de mapa e localização
- **image_picker** — captura de fotos pela câmera do dispositivo
- **location** — obtenção das coordenadas GPS
- **flutter_riverpod** — gerenciamento de estado da autenticação

Curtidas e marcações de "ainda persiste" são implementadas como subcoleções no Firestore, identificadas pelo UID do usuário, garantindo que cada pessoa registre no máximo uma interação por reporte.

## Autor

**Matheus Alcântara Pereira**