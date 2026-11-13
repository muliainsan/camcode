# Vibe Coding Spec & Prompt: Flutter SnapScan (Cam & Scan) App

Dokumen spesifikasi dan panduan pengembangan aplikasi Flutter **SnapScan** (judul antarmuka: **"Cam & Scan"**). Dokumen ini telah diselaraskan dengan implementasi kode produksi terkini yang terdapat pada repositori `camcode`.

---

## 📸 Referensi Desain (Source of Truth)
- **File Referensi**: `desain.jpeg` (atau `spec/design.jpeg`)
- **Tujuan**: Menghasilkan tata letak antarmuka, proporsi tombol kartu, palet warna, overlay pemindai, dan interaksi yang presisi menyerupai referensi desain.

---

## 1. Konteks & Ringkasan Aplikasi
Aplikasi utilitas kamera, penyuntingan gambar, dan pemindai barcode/QR code berstandar **Material Design 3**. Mengutamakan UI/UX yang bersih, animasi transisi halus (*smooth*), kenyamanan navigasi satu tangan, tata letak responsif, dan penanganan perizinan (*runtime permissions*) yang aman tanpa crash.

### Fitur Utama:
1. **Ambil & Edit Gambar (Camera & Edit)**
   - Mengambil foto langsung dari kamera perangkat bawaan.
   - Memotong (*crop*) dengan berbagai preset rasio (asli, 1:1, 4:3, 16:9).
   - Memutar (*rotate*) 90° searah jarum jam secara instan dan diproses presisi pada level *byte image*.
   - Menyimpan hasil foto ke galeri perangkat dengan konfirmasi *haptic feedback* dan notifikasi status mengambang (*floating pill toast*).
2. **Pemindai Barcode & QR Code (Barcode Scanner)**
   - Pemindaian barcode 1D dan QR code 2D secara *real-time* dengan kamera langsung.
   - *Viewfinder overlay* berlatar gelap dengan sudut *glowing neon cyan* animasi berdenyut.
   - Kontrol lampu kilat/senter (*torch*) dan penggantian kamera depan/belakang (*flip camera*).
   - *Modal Bottom Sheet* hasil scan dengan visualisasi garis barcode, penampil teks hasil pindai, tombol **Salin Data** ke *clipboard*, dan tombol **Scan Lagi**.
3. **Tata Letak Dinamis & Responsif**
   - Kartu menu utama didesain dengan rasio 1:1 (bujur sangkar proporsional).
   - **Layar Lebar (Tablet / Desktop / Landscape >= 600px)**: Kartu menu otomatis tampil berdampingan (**Kanan - Kiri**).
   - **Layar Kecil (Smartphone Portrait < 600px)**: Kartu menu otomatis tersusun vertikal (**Atas - Bawah**).
4. **Penanganan Izin Aman (Anti-Crash)**
   - Pengecekan izin kamera dan galeri secara dinamis dan aman dari *crash*.
   - Menyediakan dialog peringatan edukatif dengan tombol langsung ke Pengaturan Perangkat (`openAppSettings()`) jika izin ditolak permanen.

---

## 2. Tech Stack & Dependencies Terkini
Daftar package resmi yang digunakan pada `pubspec.yaml`:

| Package | Versi | Fungsi Utama |
|---|---|---|
| `image_picker` | `^1.2.4` | Membuka antarmuka kamera bawaan perangkat untuk mengambil foto beresolusi penuh. |
| `image_cropper` | `^13.0.0` | Antarmuka interaktif pemotongan gambar (uCrop untuk Android & iOS, dialog untuk Web). |
| `image_gallery_saver` | `^2.0.3` | Menyimpan *byte image* hasil edit langsung ke galeri / penyimpanan media perangkat. |
| `mobile_scanner` | `^7.5.0` | Pemindaian barcode dan QR code kamera *live-feed* berkecepatan dan akurasi tinggi. |
| `permission_handler` | `^13.0.2` | Pengelolaan izin akses runtime (kamera, galeri, foto, penyimpanan). |
| `image` | `^4.12.0` | Memproses rotasi 90° pada *raw byte* citra (`img.copyRotate`) sebelum disimpan ke penyimpanan permanen. |
| `flutter/services.dart` | *Built-in* | Umpan balik getaran (*haptic feedback*), akses *clipboard*, dan konfigurasi tema *status bar*. |
| `cupertino_icons` | `^1.0.8` | Koleksi ikon pendukung antarmuka iOS/Cupertino. |

---

## 3. Design System & "The Vibe" (Material Design 3)

### Palet Warna Resmi (`AppColors`):
- **Primary (Indigo/Deep Blue)**: `#3949AB`
- **Primary Dark**: `#283593`
- **Primary Light**: `#5C6BC0`
- **Background Utama (Off-White)**: `#F7F8FA`
- **Surface**: `#FFFFFF`
- **Dark Surface (Layar Pratinjau)**: `#1E1E1E`
- **Accent / Success (Emerald Green)**: `#00A86B` (Gelap: `#008F5B`)
- **Scanner Viewfinder Glow (Neon Cyan)**: `#4CE0D2` (Transparan: `0x804CE0D2`)
- **Toast Background (Dark Slate Pill)**: `#262C36`
- **Tipografi Utama**: Dark `#1A1F2C`, Muted `#757575`, Light `#FFFFFF`

### Karakteristik Visual & Pengalaman Pengguna (UX):
- **Tipografi**: Font *Roboto* modern dengan *letter-spacing* yang nyaman dibaca.
- **Card**: Sudut melengkung halus (`BorderRadius.circular(20)`), elevasi lembut dengan *ambient box-shadow*, dan efek sentuh *InkWell*.
- **Transisi**: Menggunakan `CupertinoPageTransitionsBuilder` untuk animasi perpindahan halaman yang mulus di Android maupun iOS.
- **Haptic Feedback**: Getaran responsif pada setiap interaksi tombol (`lightImpact`), deteksi barcode (`heavyImpact`), dan pergantian senter/kamera (`selectionClick`).

---

## 4. Struktur Layar & Alur Interaksi

### Screen 1: Home Screen (`MainMenuScreen`)
- **AppBar**:
  - Judul: `"Cam & Scan"` (rata tengah, warna teks putih tebal, latar Indigo `#3949AB`, elevasi 0).
- **Body**:
  - Teks instruksi: `"Pilih fitur yang ingin digunakan:"` (font size 24, font weight 700).
  - Menggunakan `LayoutBuilder` untuk adaptasi responsif:
    - **Layar >= 600px**: Baris horisontal (`Row`) berisi 2 kartu bujur sangkar (maksimal lebar 280px per kartu).
    - **Layar < 600px**: Kolom vertikal (`Column`) berisi 2 kartu bujur sangkar (maksimal lebar 330px per kartu).
  - **Card 1 ("Ambil & Edit Gambar")**:
    - Ikon kamera kustom (`CameraIconWidget`) berwarna Indigo dengan badge pensil edit putih-indigo di pojok kanan bawah.
    - Judul: `"Ambil & Edit Gambar"`.
    - Subtitle: `"Ambil foto, potong, putar, dan simpan"`.
    - Aksi: Menampilkan Modal Bottom Sheet pilihan sumber gambar (*"Kamera"* vs *"Galeri"*).
      - Jika memilih **Kamera**: Memeriksa izin kamera -> membuka kamera bawaan via `image_picker` (`ImageSource.camera`).
      - Jika memilih **Galeri**: Memeriksa izin galeri -> membuka pemilih foto via `image_picker` (`ImageSource.gallery`).
      - Setelah foto dipilih: Berpindah ke `EditPreviewScreen`.
  - **Card 2 ("Scan Barcode")**:
    - Ikon barcode kustom (`BarcodeIconWidget`) dengan 4 sudut braket pembatas dan garis barcode vertikal.
    - Judul: `"Scan Barcode"`.
    - Subtitle: `"Pindai & ambil data dari barcode"`.
    - Aksi: Memeriksa izin kamera -> berpindah ke `ScannerScreen`.

---

### Screen 2: Camera & Edit Screen (`EditPreviewScreen`)
- **AppBar**:
  - Judul: `"Preview & Edit"` (rata tengah, tombol kembali panah putih di sebelah kiri).
- **Area Pratinjau Tengah**:
  - Menggunakan latar belakang gelap (`#1E1E1E`).
  - Menampilkan gambar menggunakan `Image.memory` berbasis `Uint8List` agar kompatibel lintas platform (Web, Android, iOS, Desktop) tanpa kendala `Image.file`.
  - Dilengkapi overlay bingkai pemotretan (`CropGridOverlay`) berupa 4 sudut L-bracket putih dan garis kisi bantu 3x3 (*rule-of-thirds*).
- **Bottom Action Bar (Container Putih)**:
  - Tombol **"Potong"**: Ikon `Icons.crop`, membuka `ImageCropper` untuk pemotongan gambar fleksibel.
  - Tombol **"Putar"**: Ikon `Icons.rotate_right_rounded`, merotasi tampilan 90° (`_quarterTurns = (_quarterTurns + 1) % 4`).
  - Tombol **"Simpan ke Galeri"**: Tombol pil hijau Emerald (`#00A86B`) dengan ikon `Icons.save_rounded`.
- **Alur Penyimpanan**:
  1. Memeriksa izin galeri/penyimpanan melalui `PermissionHelper`.
  2. Jika gambar telah dirotasi, panggil `img.copyRotate` pada *bytes* gambar untuk memastikan rotasi tersimpan permanen.
  3. Simpan ke galeri menggunakan `ImageGallerySaver.saveImage`.
  4. Berikan getaran *haptic feedback* (`heavyImpact`).
  5. Tampilkan notifikasi pil gelap mengambang (*floating SnackBar*): `✅ Gambar berhasil disimpan!`.
  6. Beri jeda 1.5 detik, lalu otomatis *pop* kembali ke menu utama.

---

### Screen 3: Barcode Scanner Screen (`ScannerScreen`)
- **AppBar**:
  - Judul: `"Scan Barcode"` (rata tengah).
  - Aksi kanan: Tombol *flip camera* (`Icons.cameraswitch_rounded`) dan tombol senter (*torch toggle*).
- **Kamera Live-Feed**:
  - Menggunakan `MobileScanner` dengan `MobileScannerController` (kecepatan normal, batas waktu deteksi 250ms).
- **Overlay Viewfinder (`ScannerOverlay`)**:
  - Cutout transparan di bagian tengah dengan latar semi-gelap di sekelilingnya.
  - Sudut bingkai berwarna *neon cyan* bercahaya (`#4CE0D2`) dengan animasi denyut (*pulse glow*).
- **Alur Deteksi & Modal Bottom Sheet**:
  1. Saat barcode/QR terdeteksi, kunci status pemrosesan (`_isProcessing = true`) agar tidak memicu deteksi ganda.
  2. Jalankan *haptic feedback* (`heavyImpact`).
  3. Munculkan `showModalBottomSheet` (`ScanResultSheet`):
     - *Handle bar* abu-abu di bagian atas.
     - Chip nama format barcode (misal `QR_CODE`, `CODE_128`, `EAN_13`).
     - Ilustrasi grafis barcode dan teks kode yang dapat dipilih (*SelectableText*).
     - Tombol **"Salin Data"** (Filled Indigo): Menyalin teks ke *clipboard*, memberi *haptic feedback*, dan menampilkan *SnackBar* konfirmasi sukses.
     - Tombol **"Scan Lagi"** (Outlined): Menutup *bottom sheet* dan mengaktifkan kembali pemindai kamera secara otomatis.

---

## 5. Modul Penanganan Perizinan (`PermissionHelper`)
Terletak di `lib/utils/permission_helper.dart` dengan logika keamanan berikut:
1. **Platform Awareness**: Bypass otomatis pada platform Web (`kIsWeb`), karena perizinan ditangani langsung oleh dialog browser.
2. **Izin Kamera**:
   - Jika sudah berstatus `isGranted`, langsung lanjutkan aksi.
   - Jika `isPermanentlyDenied`, munculkan `AlertDialog` dengan tombol langsung menuju `openAppSettings()`.
   - Jika ditolak biasa, tampilkan `SnackBar` merah informatif tanpa menyebabkan *force close* / *crash*.
3. **Izin Galeri / Penyimpanan**:
   - Menyesuaikan Android 13+ (memeriksa `Permission.photos` terlebih dahulu) dan Android 12 ke bawah (`Permission.storage`).
   - Menyediakan dialog panduan jika izin ditolak secara permanen.

---

## 6. Struktur File Proyek (`camcode/lib/`)
```text
lib/
├── constants/
│   └── app_colors.dart            # Konstanta palet warna Material 3 & tema
├── utils/
│   └── permission_helper.dart     # Penanganan runtime permissions kamera & storage aman
├── widgets/
│   ├── feature_card.dart          # Kartu menu interaktif 1:1 (square) dengan haptic
│   ├── camera_icon_widget.dart    # Ikon kustom kamera + badge pensil
│   ├── barcode_icon_widget.dart   # Ikon kustom barcode dengan framing brackets
│   ├── crop_grid_overlay.dart     # Viewfinder grid 3x3 untuk layar preview gambar
│   ├── scanner_overlay.dart       # Cutout fullscreen & sudut glowing cyan berdenyut
│   └── scan_result_sheet.dart     # Bottom sheet hasil scan barcode & aksi salin
├── screens/
│   ├── main_menu_screen.dart      # Layar utama (responsif wide/narrow layout)
│   ├── edit_preview_screen.dart   # Layar pratinjau foto, rotasi byte, crop, dan simpan
│   └── scanner_screen.dart        # Layar live view pemindai barcode & kontrol senter
└── main.dart                      # Root widget, tema, dan inisialisasi aplikasi
```

---

## 7. Konfigurasi Native Tambahan

### Android (`android/app/src/main/AndroidManifest.xml`):
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Perizinan Kamera & Penyimpanan Media -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32" />

    <application ...>
        <!-- Activity untuk Image Cropper (uCrop) -->
        <activity
            android:name="com.yalantis.ucrop.UCropActivity"
            android:screenOrientation="portrait"
            android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>
    </application>
</manifest>
```

### iOS (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>SnapScan memerlukan akses kamera untuk mengambil foto dan memindai barcode.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>SnapScan memerlukan akses ke galeri untuk melihat dan menyimpan foto hasil edit.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>SnapScan memerlukan izin untuk menambahkan foto hasil edit ke galeri perangkat Anda.</string>
```
