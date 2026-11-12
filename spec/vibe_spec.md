Vibe Coding Prompt: Flutter SnapScan App

Instruksi untuk AI / LLM:
Tolong bertindak sebagai Senior Flutter Developer. Saya ingin Anda membuatkan kode lengkap untuk aplikasi Flutter bernama "SnapScan" (atau "Cam & Scan") berdasarkan panduan vibe, spesifikasi desain, dan fitur di bawah ini. Tolong buatkan kodenya sedemikian rupa agar bersih, modular, dan langsung bisa dijalankan.

REFERENSI DESAIN (PENTING):
Saya telah melampirkan/menyediakan gambar referensi UI dengan nama file desain.jpeg. Tolong gunakan gambar tersebut sebagai referensi utama (Source of Truth) untuk membuat tata letak (layout), proporsi Card, penempatan tombol, overlay scanner, dan elemen antarmuka lainnya agar semirip mungkin dengan gambar tersebut.

1. Konteks & Tujuan

Aplikasi ini adalah utilitas sederhana namun terlihat sangat profesional. Fokus utamanya adalah UI/UX yang clean, mulus (smooth), dan user-friendly (mudah dioperasikan dengan satu tangan).

Fitur Utama:

Mengambil foto dari kamera, melakukan edit ringan (crop/rotate), dan menyimpan ke galeri.

Melakukan scan barcode/QR code dan menyalin hasilnya.

2. Tech Stack & Dependencies

Pastikan Anda menggunakan versi terbaru atau yang stabil dari package berikut (asumsikan sudah ditambahkan di pubspec.yaml):

camera (Untuk akses kamera native)

image_cropper (Untuk fungsi crop & rotasi gambar)

image_gallery_saver (Untuk menyimpan gambar ke galeri device)

mobile_scanner (Untuk scan barcode/QR code)

permission_handler (Untuk meminta izin akses kamera & storage)

flutter/services.dart (Untuk fitur Haptic Feedback dan Clipboard)

3. Design System & "The Vibe"

Aplikasi ini harus mengusung Material Design 3, dengan memperhatikan komposisi visual pada file desain.jpg.

Warna Utama (Primary): Indigo (#3F51B5) atau Deep Purple.

Warna Latar (Background): Off-White (#F8F9FA).

Warna Aksi Sukses (Accent): Emerald Green (#2ECC71).

Font/Tipografi: Gunakan font default (Roboto) namun dengan TextTheme yang modern (ukuran teks besar di tombol).

Vibe UX: Tambahkan animasi transisi standar yang mulus, Haptic Feedback saat tombol ditekan atau barcode berhasil di-scan, dan gunakan Card dengan elevation yang lembut (soft shadow).

4. Struktur Layar (Screens)

Tolong buatkan minimal 3 layar berikut, dan sesuaikan detailnya dengan desain.jpg:

Screen 1: Home Screen (MainMenuScreen)

App Bar: Judul "Cam & Scan" atau "SnapScan" (tengah).

Body: Teks header "Pilih fitur yang ingin digunakan:".

Widget: 2 buah Card besar bergaya tombol (bisa di-tap menggunakan InkWell).

Card 1: Ikon Kamera besar, teks "Ambil & Edit Gambar". Mengarah ke fitur Kamera.

Card 2: Ikon Barcode besar, teks "Scan Barcode". Mengarah ke fitur Scanner.

Vibe: Layout rata tengah (Center), jarak antar elemen lega (spacious).

Screen 2: Camera & Edit Screen (EditPreviewScreen)

Alur: Saat Card 1 di-tap, jalankan kamera bawaan/plugin camera untuk mengambil foto. Setelah foto diambil, masuk ke EditPreviewScreen.

UI Layar Edit:

Gambar hasil jepretan mendominasi layar (di tengah).

Di bawah (BottomNavigationBar / Row), terdapat 3 aksi utama:

Crop: Membuka UI image_cropper.

Putar (Rotate): Memutar gambar.

Simpan ke Galeri (Tombol Hijau): Menyimpan gambar menggunakan image_gallery_saver.

Notifikasi: Setelah berhasil disimpan, munculkan Snackbar sukses berwarna hijau di bawah ("✅ Gambar berhasil disimpan!"), berikan haptic feedback, lalu pop (kembali) ke Home Screen.

Screen 3: Barcode Scanner Screen (ScannerScreen)

UI: Menggunakan kamera live view secara full screen dari mobile_scanner.

Overlay: Buat overlay semi-transparan dengan kotak fokus (frame) di tengah layar agar user tahu ke mana harus mengarahkan barcode (persis seperti di desain.jpg).

Interaksi:

Saat barcode terdeteksi -> Beri haptic feedback -> Pause kamera.

Tampilkan showModalBottomSheet berisi hasil scan.

Di dalam Bottom Sheet, sediakan 2 tombol: "Salin Data" (copy ke clipboard menggunakan Clipboard.setData) dan "Scan Lagi" (tutup bottom sheet dan resume kamera).

5. Rules & Edge Cases (Penting!)

Permission Handling: Tangani izin akses. Jika user menolak izin kamera atau galeri, tampilkan pesan error yang jelas atau tombol untuk membuka Settings.

Loading State: Saat sedang memproses crop atau menyimpan gambar, tampilkan CircularProgressIndicator.

Clean Code: Pisahkan UI komponen menjadi widget-widget kecil jika dirasa terlalu panjang, dan berikan komentar pada fungsi utama (logic kamera dan scanner).

Output yang diharapkan:
Berikan saya struktur kode lengkap (terutama bagian main.dart dan file-file screen). Anda bisa merangkumnya dalam struktur file modular atau menjadikannya satu file main.dart yang lengkap dan terstruktur dengan baik.