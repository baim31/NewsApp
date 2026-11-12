# Product Requirements Document (PRD) — News App (Front-End)

## 1. Ringkasan Proyek
Aplikasi pembaca berita berbasis Flutter (Dart) untuk tahap belajar front-end siswa. Pada tahap ini, aplikasi beroperasi sepenuhnya menggunakan data tiruan (mock data JSON lokal) tanpa dependensi backend API langsung. Fokus utama pengembangan adalah pemisahan logika bisnis menggunakan Provider, arsitektur berbasis antarmuka (interface-based), penanganan state antarmuka secara komprehensif, serta kode yang mudah dipelajari.

---

## 2. Batasan Teknis & Dependensi
- **Framework:** Flutter SDK
- **State Management:** `provider` (hanya package ini yang diizinkan)
- **Networking/HTTP:** Dilarang menggunakan package `http` atau API eksternal pada tahap ini.
- **Penyimpanan:** In-memory state (tidak menggunakan Shared Preferences, Hive, atau SQLite).
- **Desain & Tema:** Sentralisasi warna, ukuran teks, dan jarak/padding di `lib/theme/app_theme.dart`. Tidak ada styling/hardcoded color langsung di widget.
- **Bahasa Antarmuka:** Seluruh teks yang tampil di UI wajib berbahasa Indonesia.
- **Komentar Kode:** Wajib menyertakan komentar edukatif singkat berbahasa Indonesia pada implementasi `Future`, `async/await`, `fromJson`, dan Provider.

---

## 3. Struktur Folder Proyek
```text
lib/
├── models/
│   └── article.dart
├── services/
│   ├── news_service.dart
│   └── mock_news_service.dart
├── providers/
│   ├── news_provider.dart
│   └── bookmark_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── detail_screen.dart
│   └── bookmark_screen.dart
├── widgets/
│   ├── article_card.dart
│   ├── state_views.dart
│   └── bookmark_button.dart
└── theme/
    └── app_theme.dart
assets/
└── mock/
    └── articles.json