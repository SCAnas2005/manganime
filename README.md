# MangAnime – Application Mobile de Recommandation Adaptative


**Membres de l’équipe :**

- AKHTAR Danyaal
- BEN JILLANI Mohammed
- GONCALVES DOS SANTOS Ilario
- HADRI Anas
- MADRAZ Elies
- TRAORÉ Karim

## Description du projet

**Manganime** est une application mobile développée en Flutter dont l’objectif est d’offrir une **recommandation adaptative de mangas et d’animes fonctionnant en mode hors connexion**.

L’application repose sur une **base de données locale embarquée**, contenant environ **300 animes et 300 mangas**, permettant une utilisation complète **sans accès à Internet**.

- **Débutants** : découvrir facilement des œuvres populaires, accessibles et bien notées
- **Connaisseurs** : obtenir des suggestions plus ciblées en fonction des interactions et préférences personnelles

L’application **n’exige aucun compte utilisateur**.  
L’ensemble des données (likes, favoris, préférences, historique) est stocké localement sur l’appareil, permettant un apprentissage progressif et autonome du système de recommandation.

## Fonctionnalités principales

### Pages principales

- **Animes et mangas**
  - Onglet _Pour toi_ (recommandations personnalisées)
  - Onglet _Tendances_ (top, popularité, animes en diffusion)
- **Favoris**
  - Liste des animes et mangas likés
  - Mode d’affichage adaptatif : Grid / Liste
  - Like / Unlike synchronisé en temps réel
- **Statistiques**
  - Analyse des genres préférés
  - Comptage des likes
  - Tendances personnelles  
     _(selon les fonctionnalités réellement intégrées)_
- **Paramètres**
  - Apparence (clair/sombre)
  - Gestion locale
  - Informations sur l’application

### Système de likes & recommandations

- Like possible depuis toutes les pages (cartes + fiches détaillées)
- Stockage local via **Hive**
- Les items likés alimentent :
  - La page **Favoris**
  - Le modèle de **recommandation adaptative**
- L’application ajuste les recommandations selon :
  - Les genres les plus likés
  - Les types d’œuvres consultées
  - L'historique des préférences de l’utilisateur

Le système fonctionne **entièrement hors connexion**

### Page Détail (Anime / Manga)

Chaque fiche contient :

- Image 
- Titre
- Genres
- Synopsis (présent dans la base locale)
- Informations additionnelles (score, popularité, épisodes/chapitres…)
- Bouton Like + animation
- Navigation fluide au sein de l’application

### Stack technique

| Technologie        | Rôle                                         |
| ------------------ | -------------------------------------------- |
| **Flutter (Dart)** | Développement mobile                         |
| **Hive**           | Stockage local rapide (likes, favoris)       |
| **Provider**       | Gestion de l'état global                     |

## Sources de données

Les données ont été initialement récupérées via :

- **Jikan API (MyAnimeList)** : [https://jikan.moe](https://jikan.moe)
- **AniList API** : [https://anilist.co](https://anilist.co)
    
Ces APIs ont servi **uniquement à constituer la base de données locale** (titres, genres, synopsis, notes, images).  
**L’application finale ne dépend pas des APIs pour fonctionner.**

## Architecture du projet

- **MVVM (Model – View – ViewModel)**
- Séparation claire entre :
  - Modèles (Anime, Manga, AnimeDetail, MangaDetail…)
  - ViewModels (gestion de l’état + appels API)
  - Widgets UI (Cards, ListItems, AdaptativeDisplay…)
- Navigation avec `Navigator.push`
- État global avec **Provider**

### Structure du projet

```text
lib/
 ├── app/
 ├── models/           → Anime, Manga, détails...
 ├── providers/        → Gestion de l'état global
 ├── services/         → Jikan/AniList API + Traduction
 ├── theme/            → Thème et styles de l'application
 ├── viewmodels/       → Gestion des états et logique métier pour les vues
 ├── views/            → Pages du projet
 ├── widgets/          → Composants UI (cards, listes...)
 └── main.dart
```

## Installation et lancement

### Prérequis

- Flutter **3.38.3** ou supérieur
- Dart **3.10.1**
  - Android Studio ou VSCode
- SDK Android installé

**1. Cloner le projet**

```bash
git clone https://github.com/SCAnas2005/manganime.git
cd manganime
```

**2. Installer les dépendances**

```bash
flutter pub get
```

Si nécessaire :

```bash
flutter doctor --android-licenses
```

**3. Configurer l'émulateur**

Lister les émulateurs disponibles

```bash
flutter emulators
```

Lancer l'émulateur

```bash
flutter emulators --launch <nom_de_l_emulateur>
```

**4. Lancer l'application**

Lister les appareils disponibles

```bash
flutter devices
```

Exécuter l'application sur un appareil précis

```bash
flutter run -d <id_du_device>
```
