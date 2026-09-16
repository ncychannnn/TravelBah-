# TravelBah!

TravelBah! is a Flutter mobile travel community application developed to promote tourism in Sabah. The app helps users discover travel posts, share travel experiences, upload journey photos, interact with other travelers, and save favourite destinations in one place.

The name "TravelBah!" is inspired by the Sabahan word "Bah", reflecting the friendly local spirit of Sabah.

## Project Overview

TravelBah! combines destination discovery, community sharing, photo uploads, wishlist saving, and profile management into a single mobile app. It was developed as a university mobile application development project using Flutter, Firebase, Cloud Firestore, and Cloudinary.

## Core Features

- User registration and login
- Forgot password and change password
- Explore page with search, category filtering, and sorting
- Community feed for viewing travel stories
- Create, edit, and delete travel posts
- Upload travel post images
- Like and comment on posts
- Edit and delete user comments
- Save and remove posts from wishlist
- Profile management with username and profile picture updates
- Travel activity statistics for posts, likes, and saved items

## Tech Stack

- **Flutter** - Mobile application framework
- **Dart** - Application programming language
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - Real-time database for users, posts, comments, likes, and wishlist data
- **Cloudinary** - Image upload and hosting
- **Image Picker** - Image selection from device gallery
- **Google Fonts** - App typography

## Project Structure

```text
lib/
  main.dart
  models/
    comment_model.dart
    post_model.dart
  pages/
    add_post_page.dart
    community_page.dart
    explore_page.dart
    home_page.dart
    login_page.dart
    profile_page.dart
    register_page.dart
    travel_story_page.dart
    wishlist_page.dart
  services/
    auth_service.dart
    cloudinary_service.dart
    firestore_service.dart
  utils/
    app_colors.dart
    app_theme.dart
  widgets/
    comment_sheet.dart
    post_card.dart
    custom_button.dart
    custom_textfield.dart
```

## Getting Started

### Prerequisites

Make sure you have the following installed:

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- A configured Firebase project
- A Cloudinary account and upload preset

### Installation

1. Clone the repository.

```bash
git clone https://github.com/ncychannnn/TravelBah-.git
```

2. Navigate into the project folder.

```bash
cd TravelBah-
```

3. Install dependencies.

```bash
flutter pub get
```

4. Run the app.

```bash
flutter run
```

## Firebase Setup

This project uses Firebase Authentication and Cloud Firestore. To run the app with your own Firebase project, configure Firebase for Flutter and include the required Firebase configuration files.

The app expects Firebase to be initialized through `firebase_options.dart`.

## Cloudinary Setup

Image uploads are handled through Cloudinary. Update the Cloudinary configuration in:

```text
lib/services/cloudinary_service.dart
```

Set your own Cloudinary cloud name and upload preset before deploying the app.

## Current Status

TravelBah! is currently a functional mobile app prototype. The main modules have been implemented, including authentication, explore, community, post sharing, wishlist, and profile management.

## Future Improvements

- Travel itinerary planner
- Offline access for previously viewed destinations
- Location-based destination recommendations
- Personalized attraction suggestions
- Improved moderation and reporting tools

## Team

Developed by team Error 404 as part of a university mobile application development project.
