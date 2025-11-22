# 🃏 Blackjack – Application Flutter

Application mobile de **Blackjack** développée en **Flutter/Dart**, dont l’objectif est de simuler le jeu tel qu’il est pratiqué dans les casinos français.

> Les règles sont basées sur l’*Arrêté du 14 mai 2007 relatif à la réglementation des jeux dans les casinos*,
> notamment les articles **55-4** et **55-5** concernant le fonctionnement du blackjack et les minima/maxima des mises.

> ⚠️ Application réalisée **à des fins ludiques et pédagogiques uniquement**.
> Elle ne permet ni jeux d’argent réels, ni paris en ligne.

---

## 🎯 Objectifs de l’application

- Proposer une expérience de **blackjack fidèle à la législation française**.
- Servir de **projet d’exemple Flutter** illustrant une architecture propre (MVP), une logique métier découplée, et une suite de tests complète.
- Préparer le terrain pour de futures fonctionnalités avancées (options, variantes, statistiques…).

---

## 🧩 Règles principales implémentées

Conformément à la réglementation française des casinos (Arrêté du 14 mai 2007) :

- **Sabot** : Utilisation de **6 jeux de 52 cartes** (312 cartes).
- **Distribution** :
  - Le croupier **brûle les 5 premières cartes** du sabot au début.
  - Toutes les cartes (joueur et croupier) sont distribuées **face visible**.
- **Le croupier** :
  - **Tire jusqu’à 16**.
  - **Reste à 17 ou plus** (y compris 17 « soft » avec un As compté 11).
- **Paiements** :
  - **Blackjack naturel** (21 avec deux cartes) payé **3 pour 2**.
  - Égalité (`push`) lorsque le joueur et le croupier ont la même valeur de main.
- **Actions du joueur** :
  - ✅ **Tirer** / **Rester** (`Hit` / `Stand`)
  - ✅ **Doubler la mise** (`Double Down`)
  - ✅ **Séparer les paires** (`Split`), avec règles spécifiques pour les As.
  - ✅ **Assurance** lorsque la première carte du croupier est un As.
  - ✅ **Abandonner** (`Surrender`) pour récupérer la moitié de sa mise.

> **Note** : Le jeu gère actuellement **un seul joueur**. L’architecture est cependant prête à être étendue pour gérer plusieurs mains sur la table.

---

## ✨ Fonctionnalités de l’app

- **Cycle de jeu complet** : Écran de pari, phase de jeu, affichage des résultats, puis retour au pari.
- **Système de mise** :
  - Portefeuille (`Wallet`) pour le joueur.
  - Possibilité de miser, de doubler, de séparer et d’assurer, avec déduction automatique des fonds.
  - Calcul des gains et pertes à la fin de chaque manche.
- **Affichage des cartes** avec un design moderne et lisible.
- **Gestion des mains** :
  - Calcul automatique du score (avec gestion des As 1/11).
  - Détection du blackjack naturel et des busts (> 21).
  - Mise en évidence visuelle de la main active après un `split`.
- **Gestion du croupier** fidèle aux règles françaises.

> 📸 Des captures d’écran seront ajoutées dès que l’interface sera stabilisée.

---

## 🛠️ Stack technique

- **Framework** : Flutter
- **Langage** : Dart
- **Architecture** : **MVP (Model-View-Presenter)**
  - **Model (`/models`)** : Contient la logique métier pure et les objets de données (`Board`, `Player`, `Deck`, `Card`, etc.). C’est le "cerveau" du jeu.
  - **View (`/lib/main.dart` & `/views`)** : Couche d’affichage "stupide" qui se contente de présenter les données et de capturer les interactions de l’utilisateur.
  - **Presenter (`/presenters`)** : Fait le lien entre la View et le Model. Reçoit les actions de l’utilisateur, met à jour le modèle et notifie la vue pour qu’elle se rafraîchisse.
- **Tests** :
  - **Tests Unitaires** : Couverture complète de la logique métier (`Player`, `Deck`, `Dealer`) et du `HomePagePresenter`. Les tests sont déterministes et n’utilisent pas de hasard.
  - **Tests de Widgets** : Un premier test de widget pour le `CardView` a été créé pour valider la correction de l’affichage.

---

## 🚀 Prise en main

### 1. Prérequis

- Flutter installé : [Documentation officielle](https://docs.flutter.dev/get-started/install)
- Un émulateur ou un appareil physique (Android ou iOS).

### 2. Lancer l’application

```bash
# Cloner le projet
git clone https://github.com/<ton-user>/blackjack.git
cd blackjack

# Installer les dépendances
flutter pub get

# Lancer l’application
flutter run
```
