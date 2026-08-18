# Bogor Kerja ID — Panduan Menyelesaikan Build & Upload ke Play Console

Project Flutter ini adalah hasil adaptasi dari aplikasi **Loker Cilegon ID** menjadi
**Bogor Kerja ID**, sudah disambungkan ke backend `https://bogorkerja.id` (endpoint
API-nya sudah cocok 1:1 dengan yang dipakai app, karena backend Laravel-nya memang
sudah disiapkan untuk app Flutter ini — lihat `routes/api.php`).

Yang **sudah** saya kerjakan di dalam project ini:

- [x] Nama package Android diganti: `id.lokercilegon.loker_cilegon` → `id.bogorkerja.app`
- [x] Nama app diganti jadi "Bogor Kerja ID" (manifest, konstanta, dialog "Tentang", teks share)
- [x] Base URL API default diganti ke `https://bogorkerja.id`
- [x] Warna tema (primary) diganti ke navy sesuai logo Bogor Kerja (`#0C3B4D`)
- [x] Ikon app & splash screen diganti pakai logo Bogor Kerja (source: `android-chrome-512x512.png` dari public_html kamu)
- [x] Semua teks/link yang masih menyebut "Loker Cilegon"/"Cilegon" sudah disesuaikan
- [x] **Keystore & password signing produksi milik app Loker Cilegon SUDAH DIHAPUS** dari
      project ini (tidak ikut ter-copy) — jangan pernah pakai ulang keystore App A untuk App B.
- [x] `google-services.json` lama (punya project Firebase App Loker Cilegon) **dihapus**,
      karena tidak valid untuk package name baru.

## Yang HARUS kamu lakukan sendiri (butuh akses akun Google/Firebase/Play Console kamu — tidak bisa saya lakukan dari sini)

### 1. Setup Flutter di komputer lokal
Saya tidak punya Flutter SDK di lingkungan ini, jadi saya tidak bisa mengompilasi APK/AAB.
Install Flutter SDK (kalau belum ada) → https://docs.flutter.dev/get-started/install, lalu:

```bash
cd bogorkerja_app
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### 2. Buat Firebase project baru untuk Bogor Kerja
Jangan pakai Firebase project punya Loker Cilegon.

1. Buka https://console.firebase.google.com → **Add project** → beri nama "Bogor Kerja ID"
2. Tambahkan Android app dengan package name **`id.bogorkerja.app`**
3. Download `google-services.json` yang dihasilkan
4. Taruh file itu di `android/app/google-services.json`
5. Aktifkan **Cloud Messaging** di project itu (untuk notifikasi lowongan baru)
6. Backend Laravel kamu (`bogorkerja.id`) juga perlu di-set server key/service account Firebase
   yang baru ini supaya endpoint `/api/v1/devices` bisa kirim push notification dengan benar
   (cek kode di `app/Http/Controllers/Api/V1/DeviceController.php` & config FCM di backend).

### 3. Buat keystore baru khusus Bogor Kerja (JANGAN pakai keystore Loker Cilegon)

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Simpan file `.jks` ini di `android/keystore/upload-keystore.jks`, lalu isi
`android/key.properties` (sudah saya siapkan template-nya) dengan password yang kamu buat.
**Simpan file keystore ini baik-baik** — kalau hilang, kamu tidak bisa update app ini lagi di Play Store selamanya.

### 4. Build App Bundle untuk Play Console

```bash
flutter build appbundle --release
```

Hasilnya ada di `build/app/outputs/bundle/release/app-release.aab`.

### 5. Siapkan listing di Google Play Console
Hal-hal ini murni administratif, harus kamu isi sendiri di akun Play Console kamu:
- Judul, deskripsi singkat/panjang app
- Screenshot (minimal 2, disarankan pakai screenshot dari flow app yang sudah ganti tema navy)
- Ikon 512x512 (bisa pakai `assets/icon/app_icon.png` yang sudah saya generate)
- Feature graphic 1024x500
- Content rating questionnaire
- **Data safety form** — karena app ini fetch data lowongan & (opsional) push notification,
  isi sesuai data apa saja yang benar-benar dikumpulkan (device id untuk notifikasi, dll.)
- Privacy Policy URL: `https://bogorkerja.id/privacy-policy` (route-nya sudah ada di backend kamu)

## Catatan lain
- `versionCode`/`versionName` sudah saya reset ke `1.0.0+1` di `pubspec.yaml` karena ini rilis pertama untuk app baru — sesuaikan kalau kamu mau mulai dari angka lain.
- Kalau backend `bogorkerja.id` masih pakai domain lain untuk gambar/upload (selain `bogorkerja.id/uploads/...`), cek lagi `lib/screens/home/widgets/company_grid.dart` dan `lib/screens/job_detail/widgets/job_detail_header.dart`.
