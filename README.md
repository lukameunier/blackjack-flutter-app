# 🃏 Blackjack – Application Flutter

Application mobile de **Blackjack** développée en **Flutter/Dart**, dont l’objectif est de simuler le jeu tel qu’il est pratiqué dans les casinos français.

> Les règles sont basées sur l’*Arrêté du 14 mai 2007 relatif à la réglementation des jeux dans les casinos*,  
> notamment les articles **55-4** et **55-5** concernant le fonctionnement du blackjack et les minima/maxima des mises.

> ⚠️ Application réalisée **à des fins ludiques et pédagogiques uniquement**.  
> Elle ne permet ni jeux d’argent réels, ni paris en ligne.

---

## 🎯 Objectifs de l’application

- Proposer une expérience de **blackjack fidèle à la législation française**.
- Servir de **projet d’exemple Flutter** : gestion d’état, logique métier, tests, UI réactive.
- Préparer le terrain pour de futures fonctionnalités avancées (options, variantes, statistiques…).

---

## 🧩 Règles principales implémentées / prévues

Conformément à la réglementation française des casinos (Arrêté du 14 mai 2007) :

- Utilisation de **6 jeux de 52 cartes**.
- Jusqu’à **7 places** (mains) sur la table.
- Distribution :
  - Le croupier brûle les 5 premières cartes du sabot.
  - Deux cartes face visible pour chaque joueur, une puis deux pour le croupier.
- Le croupier :
  - **tire jusqu’à 16**,
  - **reste à 17 ou plus** (y compris 17 « soft » avec un As compté 11).
- Blackjack naturel (21 avec deux cartes) payé **3 pour 2**.
- Possibilités pour le joueur :
  - **Tirer** / **Rester**
  - **Doubler** (down for double)
  - **Séparer les paires** (split), avec règles spécifiques pour les As
  - **Assurance** lorsque la première carte du croupier est un As
- Égalité (`push`) lorsque le joueur et le croupier ont la même valeur de main.

Fonctionnalités optionnelles prévues (non obligatoires dès la première version) :

- Option **« dames de cœur »**
- Option **Hyper Blackjack**
- Option **« 2 + 1 cartes »**
- Option **jackpot progressif (JP1)**

---

## ✨ Fonctionnalités de l’app

> Certaines sont déjà implémentées, d’autres en cours de développement ou prévues dans la roadmap.

- Affichage des **cartes** avec :
  - valeurs (2–10, J, Q, K, A)
  - couleurs (♥ ♦ ♣ ♠)
- Gestion des **mains** :
  - calcul automatique du score (avec gestion des As 1/11)
  - détection du blackjack et des busts (> 21)
- Gestion de la **banque / croupier** selon les règles françaises.
- Historique simple des coups (prévu).
- Paramètres futurs :
  - niveau de mise minimum/maximum
  - activation/désactivation des options avancées
- Interface pensée pour :
  - **mobile en premier** (Android / iOS),
  - puis potentiellement **Web/Desktop** via Flutter.

> 📸 Des captures d’écran seront ajoutées dès que l’interface sera stabilisée.

---

## 🛠️ Stack technique

- **Framework** : Flutter
- **Langage** : Dart
- **Architecture** : séparation claire entre
  - logique métier (cartes, mains, règles),
  - widgets de présentation,
  - gestion d’état (à préciser : `setState`, Riverpod, Provider, etc. selon ton choix).
- **Tests** :
  - tests unitaires sur la logique de cartes & règles,
  - tests de widgets pour vérifier l’interface de base.

---

## 🚀 Prise en main

### 1. Prérequis

- Flutter installé :  
  [Documentation officielle](https://docs.flutter.dev/get-started/install)
- Un émulateur ou un appareil physique (Android ou iOS).

### 2. Cloner le projet

```bash
git clone https://github.com/<ton-user>/<ton-repo>.git
cd <ton-repo>

