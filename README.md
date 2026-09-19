# TKA Cerdas

Platform LMS persiapan TKA berbasis frontend statis dan Supabase. Proyek ini sudah mencakup aplikasi siswa, panel guru/admin, bank soal, materi, latihan adaptif, mini tryout, tryout, autosave, penilaian aman, progres, riwayat, dan analisis.

## Cara paling mudah untuk Windows

Jika `schema.sql` sudah dijalankan, cukup klik dua kali `1_SETUP_SUPABASE.bat` dan ikuti tulisan di layar. Setelah selesai, klik dua kali `2_JALANKAN_APLIKASI.bat`. Untuk upload ke GitHub, buat repository kosong lalu klik dua kali `3_DEPLOY_GITHUB.bat`. File `PETUNJUK_SINGKAT.txt` berisi versi petunjuk yang sangat ringkas.

## Struktur proyek

```text
dist/
  index.html              aplikasi siswa
  admin.html              panel guru/admin
  css/styles.css
  js/app.js
  js/admin.js
  js/core.js
  js/config.js            konfigurasi lokal, tidak ikut Git
  js/config.example.js
supabase/
  schema.sql              tabel, indeks, RLS, RPC, dan view
  seed.sql                5 materi, materi belajar, 75 soal, mini tryout, tryout
  functions/              fungsi backend aman
.github/workflows/pages.yml
```

## 1. Membuat project Supabase

1. Buat project baru di [Supabase](https://supabase.com/dashboard).
2. Buka **SQL Editor**.
3. Jalankan seluruh isi `supabase/schema.sql`.
4. Setelah berhasil, jalankan `supabase/seed.sql`.
5. Di **Project Settings → API**, salin Project URL dan public anon key.

Jangan pernah menaruh `service_role` key di folder `dist`, GitHub, atau browser. Key tersebut hanya tersedia otomatis sebagai secret pada Supabase Edge Functions.

## 2. Menghubungkan frontend

Salin `dist/js/config.example.js` menjadi `dist/js/config.js`, lalu ubah:

```js
export const CONFIG = {
  SUPABASE_URL: "https://PROJECT_ID.supabase.co",
  SUPABASE_ANON_KEY: "PUBLIC_ANON_KEY",
  APP_NAME: "TKA Cerdas",
};
```

Anon key aman berada di frontend karena perlindungan data dilakukan dengan RLS. Yang tidak boleh ada di frontend adalah service role key.

Untuk penggunaan paling sederhana, `config.js` ikut dikomit. Anon key memang dirancang sebagai key publik; keamanan tetap bergantung pada RLS. Pastikan `schema.sql` dijalankan secara utuh. Jangan pernah mengganti anon key dengan service role key.

## 3. Deploy Edge Functions

Pasang Supabase CLI, login, kemudian dari root proyek jalankan:

```bash
supabase login
supabase link --project-ref PROJECT_ID
supabase functions deploy start-attempt
supabase functions deploy get-attempt
supabase functions deploy submit-attempt
supabase functions deploy manage-user
```

Keempat fungsi memakai verifikasi JWT. Supabase menyediakan `SUPABASE_URL` dan `SUPABASE_SERVICE_ROLE_KEY` secara otomatis di lingkungan Edge Functions.

Fungsi backend menangani:

- pemilihan soal tanpa mengirim seluruh bank soal ke browser;
- prioritas soal yang belum pernah dikerjakan, kemudian soal yang pernah salah;
- snapshot soal ke `attempt_questions`;
- pengambilan soal tanpa kunci jawaban;
- penilaian dan pembukaan pembahasan setelah submit;
- pembuatan akun dan reset password oleh admin.

## 4. Membuat admin pertama

Admin pertama dibuat satu kali dari Supabase Dashboard:

1. Buka **Authentication → Users → Add user**.
2. Isi email internal, misalnya `admin@tka.internal`, dan password kuat.
3. Centang **Auto Confirm User**.
4. Trigger database otomatis membuat profil dasar.
5. Buka SQL Editor lalu jalankan, dengan menyesuaikan username:

```sql
update public.profiles
set username = 'admin', full_name = 'Administrator TKA', role = 'admin', must_change_password = false
where id = (select id from auth.users where email = 'admin@tka.internal');
```

Login pada `admin.html` menggunakan username `admin` dan password yang dibuat tadi. Setelah itu, akun siswa dapat dibuat dari panel admin.

## 5. Menjalankan secara lokal

Karena JavaScript memakai ES Modules, jangan membuka HTML langsung dengan `file://`. Jalankan server statis dari root proyek:

```bash
python -m http.server 8080 --directory dist
```

Buka:

- `http://localhost:8080/` untuk siswa;
- `http://localhost:8080/admin.html` untuk guru/admin.

## 6. Deploy ke GitHub Pages

1. Buat repository GitHub baru.
2. Upload seluruh isi proyek ini, bukan hanya folder `dist`.
3. Pastikan `dist/js/config.js` yang sudah diisi ikut masuk repository.
4. Push ke branch `main`.
5. Buka **Settings → Pages**.
6. Pada Source, pilih **GitHub Actions**.
7. Workflow `.github/workflows/pages.yml` akan menerbitkan isi folder `dist`.

Semua referensi file frontend bersifat relatif, sehingga aplikasi tetap bekerja pada URL subfolder GitHub Pages.

## 7. Login username dan password

Pengguna hanya melihat username. Di balik layar, username dipetakan menjadi email internal:

```text
240018 → 240018@tka.internal
```

Akun harus dibuat melalui panel admin agar Auth dan tabel `profiles` tetap sinkron. Jangan menambahkan siswa hanya dengan `insert` langsung ke `profiles`.

## 8. Import siswa

CSV siswa memakai header:

```csv
username,nama,kelas,password
240018,Andi Saputra,XII A,Tka12345!
240019,Siti Rahma,XII A,Tka12345!
```

Ketentuan:

- nama kelas harus sama persis dengan data pada menu Kelas;
- password minimal 8 karakter;
- maksimal 200 baris per proses import;
- username hanya boleh berisi huruf, angka, titik, garis bawah, atau tanda hubung.

## 9. Import bank soal

Unduh template dari menu **Bank Soal → Template CSV**. Kolomnya:

```text
kode_soal,materi,submateri,tingkat_kesulitan,pertanyaan,
opsi_a,opsi_b,opsi_c,opsi_d,opsi_e,jawaban,pembahasan,gambar_url,sumber
```

Nilai `tingkat_kesulitan` dapat berupa `mudah`, `sedang`, atau `sulit`. Kolom `jawaban` diisi A–E. Nama materi harus sama dengan data di aplikasi.

Untuk gambar, upload terlebih dahulu ke bucket `question-images` atau penyimpanan lain, lalu isi URL publiknya. Schema sudah membuat bucket dan policy upload khusus staf.

## 10. Cara randomisasi bekerja

Saat siswa memulai latihan:

1. Edge Function memverifikasi JWT siswa.
2. Sistem membaca materi atau blueprint.
3. Sistem mengambil hanya soal aktif.
4. Soal yang belum pernah dikerjakan diprioritaskan.
5. Jika masih kurang, sistem memilih soal yang pernah salah, lalu soal lain.
6. Daftar soal diacak dan disimpan sebagai snapshot pada `attempt_questions`.
7. Browser menerima pertanyaan dan opsi tanpa `correct_option` maupun pembahasan.

Saat submit, backend membandingkan jawaban dengan kunci, menyimpan hasil, kemudian pembahasan baru dapat diminta.

## 11. Row Level Security

Aturan utama yang sudah diterapkan:

- siswa hanya dapat membaca profil dan attempt miliknya;
- siswa tidak memiliki policy untuk membaca tabel `questions`;
- siswa tidak memiliki akses langsung ke `attempt_questions`;
- autosave dilakukan melalui RPC yang memeriksa pemilik dan status attempt;
- view progres selalu difilter dengan `auth.uid()`;
- guru/admin mendapat akses pengelolaan melalui pemeriksaan role server-side;
- pembuatan akun hanya dapat dijalankan admin melalui Edge Function.

Jangan menonaktifkan RLS untuk memecahkan error frontend. Cari policy atau grant yang tepat.

## 12. Menambah mata pelajaran dan soal

Urutan yang disarankan:

1. Buat mata pelajaran.
2. Buat materi/topik.
3. Tambahkan submateri jika dibutuhkan melalui SQL atau perluasan panel.
4. Buat konten belajar.
5. Tambahkan soal manual atau import CSV.
6. Aktifkan soal.
7. Buat blueprint mini tryout/tryout.

Jumlah soal aktif setiap materi harus minimal sama dengan jumlah yang diminta blueprint. Jika kurang, sistem menolak memulai attempt dan memberi pesan jelas.

## 13. Troubleshooting

### “Aplikasi belum dikonfigurasi”

Periksa `dist/js/config.js`. Pastikan URL memakai `https://` dan anon key bukan placeholder.

### Login selalu gagal

Pastikan akun dibuat melalui panel admin atau email Auth mengikuti pola `username@tka.internal`. Pastikan user sudah confirmed.

### “Failed to send a request to the Edge Function”

Pastikan keempat fungsi sudah dideploy ke project yang sama dengan URL pada `config.js`. Cek log di **Edge Functions → Logs**.

### Mini tryout tidak dapat dimulai

Periksa jumlah blueprint dan jumlah soal aktif per materi. Total blueprint harus sama dengan `question_count`.

### Data siswa tidak muncul

Pastikan role akun admin adalah `admin` atau `teacher`, status profil `active`, dan `schema.sql` dijalankan tanpa bagian yang dilewati.

### Perubahan tidak muncul di GitHub Pages

Periksa tab **Actions**, tunggu workflow selesai, lalu lakukan hard refresh pada browser.

## 14. Checklist sebelum dipakai siswa

- Ganti password admin awal.
- Tambahkan kelas dan akun siswa.
- Periksa minimal satu materi dan satu latihan sampai halaman hasil.
- Pastikan kunci jawaban tidak muncul di Network response sebelum submit.
- Uji timer dan auto-submit.
- Periksa tampilan melalui ponsel.
- Gunakan soal final, bukan soal demo, untuk kegiatan resmi.

## Catatan pengembangan

Frontend sengaja dibuat tanpa proses build agar mudah dirawat dan cepat di GitHub Pages. Semua operasi sensitif tetap berada di Supabase. Untuk skala lebih besar, penambahan soal dapat dipindahkan ke Edge Function import agar validasi per baris lebih kuat, dan materi HTML dapat memakai editor terkontrol/sanitizer khusus.
