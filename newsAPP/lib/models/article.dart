/// Model representasi data Artikel Berita dalam aplikasi.
///
/// File ini bertanggung jawab memetakan struktur data JSON mentah menjadi objek Dart
/// yang aman terhadap tipe data (type-safe).
class Article {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String author;
  final String category;
  final DateTime publishedAt;
  final String imageUrl;
  final int readingTimeMinutes;
  final String? sourceUrl;

  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.author,
    required this.category,
    required this.publishedAt,
    required this.imageUrl,
    this.readingTimeMinutes = 3,
    this.sourceUrl,
  });

  /// [KONSEP EDUKATIF: Factory Constructor & fromJson]
  ///
  /// Dalam Dart, `factory constructor` digunakan ketika konstruktor tidak selalu membuat
  /// instance baru dari kelasnya secara langsung, melainkan dapat melakukan parsing data,
  /// validasi awal, atau mengembalikan instance yang telah diproses.
  ///
  /// Pola `fromJson` menerima `Map<String, dynamic>` (hasil pembacaan JSON mentah)
  /// dan mengubah nilai string/angka menjadi tipe data yang tepat (misalnya String menjadi DateTime).
  ///
  /// Keuntungan menggunakan pattern ini:
  /// 1. Type Safety: Menghindari runtime error akibat tipe data tidak sesuai.
  /// 2. Sentralisasi Parsing: Jika format API/JSON berubah, cukup ubah method ini saja.
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Tanpa Judul',
      summary: json['summary'] as String? ?? '',
      content: json['content'] as String? ?? '',
      author: json['author'] as String? ?? 'Redaksi',
      category: json['category'] as String? ?? 'Umum',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      imageUrl: json['imageUrl'] as String? ?? '',
      readingTimeMinutes: json['readingTimeMinutes'] as int? ?? 3,
      sourceUrl: json['sourceUrl'] as String?,
    );
  }

  /// [KONSEP EDUKATIF: Adaptasi Respons API Eksternal (Adapter Pattern)]
  ///
  /// Skema respons dari NewsAPI.org berbeda dengan skema JSON lokal kita:
  /// - `urlToImage` di NewsAPI -> kita petakan ke `imageUrl`
  /// - `description` di NewsAPI -> kita petakan ke `summary`
  /// - `source['name']` di NewsAPI -> fallback jika `author` bernilai null
  /// - `url` di NewsAPI -> kita simpan sebagai `sourceUrl` dan `id` unik artikel.
  factory Article.fromNewsApi(Map<String, dynamic> json, {String? category}) {
    final rawTitle = json['title'] as String? ?? 'Tanpa Judul';
    final description = json['description'] as String? ?? '';
    final rawContent = json['content'] as String? ?? description;

    // Bersihkan karakter potongan berita bawaan NewsAPI gratis seperti "[+1234 chars]"
    final cleanContent = rawContent.replaceAll(RegExp(r'\[\+\d+ chars\]'), '').trim();

    // Author fallback ke nama sumber jika null
    String authorName = 'Redaksi';
    if (json['author'] != null && (json['author'] as String).trim().isNotEmpty) {
      authorName = (json['author'] as String).trim();
    } else if (json['source'] != null && json['source']['name'] != null) {
      authorName = (json['source']['name'] as String).trim();
    }

    final url = json['url'] as String? ?? '';
    final uniqueId = url.isNotEmpty ? url : 'art_${rawTitle.hashCode}';

    return Article(
      id: uniqueId,
      title: rawTitle,
      summary: description.isNotEmpty ? description : 'Klik untuk membaca ulasan lengkap.',
      content: cleanContent.isNotEmpty
          ? cleanContent
          : (description.isNotEmpty ? description : 'Konten lengkap tersedia di sumber berita.'),
      author: authorName,
      category: category ?? 'Umum',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      imageUrl: json['urlToImage'] as String? ?? '',
      readingTimeMinutes: 3,
      sourceUrl: url.isNotEmpty ? url : null,
    );
  }

  /// Mengubah objek Article kembali menjadi struktur Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'author': author,
      'category': category,
      'publishedAt': publishedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'readingTimeMinutes': readingTimeMinutes,
      'sourceUrl': sourceUrl,
    };
  }

  /// Helper untuk memformat tanggal publikasi ke format yang nyaman dibaca pengguna Indonesia.
  /// Contoh: "02 Nov 2026"
  String get formattedDate {
    final bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final day = publishedAt.day.toString().padLeft(2, '0');
    final month = bulan[publishedAt.month];
    final year = publishedAt.year;
    return '$day $month $year';
  }

  /// Method copyWith untuk mendukung paradigma immutability jika ada data yang perlu diubah.
  Article copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? author,
    String? category,
    DateTime? publishedAt,
    String? imageUrl,
    int? readingTimeMinutes,
    String? sourceUrl,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      author: author ?? this.author,
      category: category ?? this.category,
      publishedAt: publishedAt ?? this.publishedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
