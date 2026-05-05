---
name: android-code-review
description: >
  Gunakan skill ini untuk review kode Android sebelum PR. Trigger saat user bilang
  "review kode", "cek perubahan", "code review", "cek PR", atau sejenisnya.
  Skill ini mengecek simplifikasi fungsi baru di ViewModel, unused imports,
  missing unit test untuk ViewModel, dan unused function/variable dari perubahan yang ada.
---

# Android Code Review Skill

Review otomatis untuk perubahan kode Android berdasarkan git diff.

## Perubahan yang akan direview

### File yang berubah
!`git diff --name-only HEAD`

### Isi perubahan
!`git diff HEAD`

---

## Phase 1: Cek Simplifikasi Fungsi Baru di ViewModel

Filter file yang berubah — cari yang namanya mengandung `ViewModel.kt`.

Untuk setiap fungsi yang **baru ditambahkan** (baris dengan tanda `+` di diff) di ViewModel, evaluasi apakah fungsi tersebut bisa disederhanakan:

- Fungsi yang bisa diganti dengan expression body (`= ...`) daripada block body `{ return ... }`
- Logika kondisional bertingkat yang bisa disederhanakan dengan `when`, `takeIf`, `let`, `run`, atau operator Elvis `?:`
- Fungsi yang hanya meneruskan call ke fungsi lain tanpa transformasi — pertimbangkan apakah fungsi wrapper-nya masih perlu
- Duplikasi logika antar fungsi baru yang bisa di-extract ke satu fungsi shared
- Penggunaan `if/else` untuk assignment yang bisa diganti ekspresi langsung

**Aturan:**
- Hanya simplifikasi fungsi yang **baru ditambahkan**, jangan ubah fungsi lama yang tidak ada di diff
- Jangan ubah behavior — simplifikasi hanya boleh mengubah bentuk kode, bukan logikanya
- Ikuti gaya kode yang sudah ada di file tersebut

**Aksi:** Terapkan simplifikasi langsung jika yakin tidak mengubah behavior. Jika ada trade-off readability, tampilkan opsi ke user dan tanya.

---

## Phase 2: Cek Unused Imports

Untuk setiap file `.kt` yang berubah, cek apakah ada import yang tidak lagi
digunakan setelah perubahan. Fokus pada:

- Import yang di-remove dari usage tapi masih ada di bagian `import`
- Import yang duplikat
- Import yang tidak direferensikan di seluruh isi file

**Cara cek:**
Baca isi file lengkap, lalu bandingkan setiap baris `import` dengan penggunaan
aktual di body file. Jika nama class/fungsi dari import tidak muncul di body,
hapus import tersebut.

**Aksi:** Hapus import yang tidak dipakai langsung di file menggunakan Edit tool.

---

## Phase 3: Cek Unit Test untuk ViewModel

Filter file yang berubah — cari yang namanya mengandung `ViewModel.kt`.

Untuk setiap ViewModel yang berubah:

1. Cari file test-nya di path: `src/test/**/*<NamaViewModel>Test.kt`
2. Jika file test **belum ada**:
   - Cari contoh file test ViewModel lain di project sebagai referensi pola
   - Buat file test baru mengikuti pola yang sama (MockK, coroutine test, dll)
   - Cover fungsi publik dan logika utama yang ada di ViewModel tersebut
3. Jika file test **sudah ada**:
   - Cek apakah ada fungsi atau logika baru dari diff yang belum ada test case-nya
   - Jika belum, tambahkan test case yang sesuai

**Aturan:**
- Ikuti struktur dan pola test yang sudah ada di project — jangan inject pola baru
- Jangan tambahkan library testing baru yang belum ada di project
- Gunakan dependency injection, mock, dan dispatcher yang sudah dipakai project

---

## Phase 4: Cek Unused Function dan Variable

Dari diff perubahan, identifikasi kode yang ditambahkan tapi tidak dipakai:

- Fungsi yang didefinisikan tapi tidak pernah dipanggil
- Variable atau property yang dideklarasikan tapi tidak pernah dibaca
- Parameter fungsi yang tidak digunakan di dalam body-nya

**Cara cek referensi:**
```bash
grep -rn "<nama_simbol>" --include="*.kt" .
```

Jika hasil grep hanya menunjukkan deklarasinya saja (tidak ada pemanggilan),
maka kode tersebut unused.

**Aksi:**
- Hapus kode yang benar-benar tidak dipakai
- Jika simbol bersifat `public` atau `internal` dan mungkin dipakai dari module lain,
  flag ke user sebelum menghapus

---

## Laporan Hasil Review

Setelah semua phase selesai, tampilkan ringkasan:

```
## Hasil Code Review

### Simplifikasi Fungsi ViewModel
- [NamaViewModel]: [deskripsi simplifikasi yang diterapkan]
- Tidak ada fungsi baru yang perlu disimplifikasi

### Unused Imports
- [nama file]: dihapus X import → [nama import]
- Tidak ada / semua import sudah bersih

### Unit Test ViewModel
- [NamaViewModel]: [test sudah ada dan lengkap / test baru dibuat / test case ditambahkan]
- Tidak ada ViewModel yang berubah

### Unused Code
- [nama file]: dihapus [fungsi/variable] → [nama simbol]
- Tidak ada unused code ditemukan
```

Jika tidak ada masalah di semua phase, tampilkan:
> "Kode sudah bersih, tidak ada yang perlu diperbaiki."
