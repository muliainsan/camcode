# SnapScan (Cam & Scan)

Aplikasi utilitas kamera dan pemindai barcode/QR code berbasis Flutter dengan desain **Material Design 3**, animasi transisi halus, tata letak responsif, dan *haptic feedback*.

Dibuat berdasarkan spesifikasi pada `spec/vibe_spec.md` dan referensi visual `spec/design.jpeg`.

---

## 📱 Fitur Utama

1. **Ambil & Edit Gambar (Camera & Edit)**
   - Integrasi kamera perangkat untuk pengambilan gambar instan.
   - Fitur **Potong (Crop)** dengan *aspect ratio* fleksibel menggunakan `image_cropper` (uCrop).
   - Fitur **Putar (Rotate)** 90° presisi yang diproses di level isolat Dart (`compute`).
   - Simpan langsung ke galeri perangkat dengan notifikasi status (*toast*) dan konfirmasi *haptic feedback*.

2. **Pemindai Barcode & QR Code (Barcode Scanner)**
   - Pemindaian real-time kecepatan tinggi menggunakan `mobile_scanner`.
   - *Viewfinder overlay* dengan sudut *glowing neon cyan* sesuai referensi desain.
   - Kontrol senter/lampu kilat (*torch toggle*).
   - *Modal Bottom Sheet* hasil pemindaian dengan visualisasi barcode, tombol **Salin Data** ke *clipboard*, dan tombol **Scan Lagi**.

3. **Tata Letak Dinamis & Responsif**
   - **Menu Card 1:1**: Ukuran panjang dan lebar kartu menu selalu proporsional (bujur sangkar).
   - **Layar Lebar (Tablet / Landscape / Desktop)**: Menu otomatis tampil berdampingan (**Kanan - Kiri**).
   - **Layar Kecil (Smartphone Portrait)**: Menu otomatis tampil bertingkat (**Atas - Bawah**).

4. **Penanganan Izin Aman (Anti-Crash)**
   - Pemeriksaan izin kamera dan penyimpanan galeri secara dinamis via `permission_handler`.
   - Dialog peringatan ramah pengguna dengan tombol langsung ke Pengaturan Perangkat (`openAppSettings()`) jika izin ditolak permanen.

---

## 📂 Struktur Proyek

```text
lib/
├── constants/
│   └── app_colors.dart            # Palet warna resmi Material 3 & tema desain
├── utils/
│   └── permission_helper.dart     # Penanganan runtime permissions kamera & penyimpanan
├── widgets/
│   ├── feature_card.dart          # Card menu interaktif 1:1 (square) dengan haptic
│   ├── camera_icon_widget.dart    # Ikon kustom kamera + badge pensil
│   ├── barcode_icon_widget.dart   # Ikon kustom barcode dengan framing brackets
│   ├── crop_grid_overlay.dart     # Viewfinder grid 3x3 untuk layar preview gambar
│   ├── scanner_overlay.dart       # Cutout fullscreen & sudut glowing cyan
│   └── scan_result_sheet.dart     # Bottom sheet hasil scan barcode & aksi salin
├── screens/
│   ├── main_menu_screen.dart      # Layar utama (responsif wide/narrow layout)
│   ├── edit_preview_screen.dart   # Layar pratinjau foto, rotasi, crop, dan simpan
│   └── scanner_screen.dart        # Layar live view pemindai barcode
└── main.dart                      # Root widget & tema aplikasi
```

---

## 🛠️ Tech Stack & Dependencies

- **Flutter SDK**: `^3.13.7` (Dart 3)
- **image_picker**: `^1.2.4`
- **image_cropper**: `^13.0.0`
- **image_gallery_saver**: `^2.0.3`
- **mobile_scanner**: `^7.5.0`
- **permission_handler**: `^13.0.2`
- **image**: `^4.12.0`

---

## 🚀 Cara Menjalankan

1. **Unduh dependencies**:
   ```bash
   flutter pub get
   ```

2. **Analisis kode & pengujian unit**:
   ```bash
   flutter analyze
   flutter test
   ```

3. **Jalankan di perangkat/emulator**:
   ```bash
   flutter run
   ```
