# gardenme 🌿

O **GardenMe** é um aplicativo mobile desenvolvido em Flutter para ajudar entusiastas e cuidadores de plantas a manterem controle total sobre a saúde e o ciclo de vida da sua vegetação.

---

## 🎯 Objetivo do Projeto

O principal objetivo do GardenMe é simplificar o cuidado com as plantas, oferecendo uma interface intuitiva onde o usuário pode:

- Monitorar necessidades específicas de cada planta  
- Configurar lembretes personalizados  
- Acompanhar o desenvolvimento da sua coleção  
- Garantir que cada planta receba a atenção necessária para florescer  

---

## 🚀 Tecnologias Utilizadas

O projeto foi desenvolvido utilizando as seguintes tecnologias e dependências principais:

### 📱 Mobile

- **Framework:** Flutter (SDK >= 3.0.0)  
- **Linguagem:** Dart  

### 🔐 Backend & Autenticação

- `firebase_core` – Inicialização do Firebase  
- `firebase_auth` – Autenticação de usuários  
- `cloud_firestore` – Banco de dados NoSQL  
- `firebase_storage` – Armazenamento de imagens e arquivos  
- `google_sign_in` – Login com conta Google  

### 🎨 Recursos Locais & Interface

- `flutter_local_notifications` – Agendamento de notificações  
- `timezone` – Gerenciamento de fuso horário para alertas  
- `circular_bottom_navigation` – Navegação personalizada  
- `image_picker` – Captura e seleção de imagens  
- `screenshot` – Captura de tela do app  
- `share_plus` – Compartilhamento de conteúdo  
- `shared_preferences` – Armazenamento local de preferências  

---

## 📲 Instalação

Você pode baixar e instalar o aplicativo através do QR Code abaixo:

<p align="center">
  <img src="assets\images\qrcode.jpeg" width="250">
</p>

---

## 👥 Contribuidores

Desenvolvido com dedicação por:

- Gabriel Aparecido  
- Douglas Balbino  

---

## 🛠️ Como Executar o Projeto

```bash
# Clone o repositório
git clone <url-do-repositorio>

# Acesse a pasta do projeto
cd gardenme

# Instale as dependências
flutter pub get

# Execute o projeto
flutter run
```