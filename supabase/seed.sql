-- Demo academic content. Safe to run after schema.sql.
-- Auth users are created through Admin UI / manage-user Edge Function, not SQL.

insert into public.classes(id,name,academic_year,status) values
('10000000-0000-0000-0000-000000000001','XII A','2026/2027','active') on conflict do nothing;

insert into public.subjects(id,name,code,description,sort_order,status) values
('20000000-0000-0000-0000-000000000001','TKA Matematika','MTK','Penalaran, pemecahan masalah, dan penerapan konsep matematika untuk TKA.',1,'active') on conflict do nothing;

insert into public.topics(id,subject_id,name,description,sort_order,status) values
('30000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','Bilangan','Operasi, sifat, rasio, dan bentuk bilangan.',1,'active'),
('30000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','Aljabar','Persamaan, fungsi, dan manipulasi bentuk aljabar.',2,'active'),
('30000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000001','Geometri','Bangun datar, ruang, koordinat, dan transformasi.',3,'active'),
('30000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000001','Statistika','Penyajian, pemusatan, dan penyebaran data.',4,'active'),
('30000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000001','Peluang','Ruang sampel, kejadian, dan peluang majemuk.',5,'active') on conflict do nothing;

insert into public.subtopics(id,topic_id,name,sort_order,status) values
('31000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','Operasi bilangan',1,'active'),
('31000000-0000-0000-0000-000000000002','30000000-0000-0000-0000-000000000002','Persamaan linear',1,'active'),
('31000000-0000-0000-0000-000000000003','30000000-0000-0000-0000-000000000003','Bangun datar',1,'active'),
('31000000-0000-0000-0000-000000000004','30000000-0000-0000-0000-000000000004','Ukuran pemusatan',1,'active'),
('31000000-0000-0000-0000-000000000005','30000000-0000-0000-0000-000000000005','Peluang kejadian',1,'active') on conflict do nothing;

insert into public.learning_materials(topic_id,title,content,sort_order,status) values
('30000000-0000-0000-0000-000000000001','Inti Materi Bilangan','<h2>Operasi dan sifat bilangan</h2><p>Perhatikan urutan operasi: kurung, pangkat, perkalian atau pembagian, kemudian penjumlahan atau pengurangan.</p><h3>Strategi TKA</h3><ul><li>Estimasi hasil sebelum menghitung.</li><li>Sederhanakan pecahan sedini mungkin.</li><li>Periksa tanda positif dan negatif.</li></ul><p><b>Contoh:</b> 18 ÷ 3 × 2 = 6 × 2 = 12.</p>',1,'active'),
('30000000-0000-0000-0000-000000000002','Inti Materi Aljabar','<h2>Persamaan dan bentuk aljabar</h2><p>Operasi yang dilakukan pada satu ruas persamaan harus dilakukan pula pada ruas lainnya.</p><p><b>Contoh:</b> 3x + 5 = 20, maka 3x = 15 dan x = 5.</p><h3>Kesalahan umum</h3><p>Jangan memindahkan suku tanpa memahami bahwa yang dilakukan adalah operasi invers pada kedua ruas.</p>',1,'active'),
('30000000-0000-0000-0000-000000000003','Inti Materi Geometri','<h2>Bangun datar</h2><p>Luas mengukur daerah dua dimensi, sedangkan keliling mengukur panjang batas bangun.</p><table><tr><th>Bangun</th><th>Luas</th></tr><tr><td>Persegi</td><td>s²</td></tr><tr><td>Segitiga</td><td>½ × alas × tinggi</td></tr><tr><td>Lingkaran</td><td>πr²</td></tr></table>',1,'active'),
('30000000-0000-0000-0000-000000000004','Inti Materi Statistika','<h2>Membaca pusat data</h2><p>Mean diperoleh dari jumlah data dibagi banyak data. Median adalah nilai tengah setelah data diurutkan. Modus adalah nilai yang paling sering muncul.</p><p>Pilih ukuran yang paling sesuai: median biasanya lebih tahan terhadap pencilan.</p>',1,'active'),
('30000000-0000-0000-0000-000000000005','Inti Materi Peluang','<h2>Peluang suatu kejadian</h2><p>Jika seluruh hasil sama mungkin, peluang kejadian A adalah banyak hasil yang mendukung A dibagi banyak anggota ruang sampel.</p><p>Nilai peluang selalu berada antara 0 dan 1.</p>',1,'active');

insert into public.questions(subject_id,topic_id,subtopic_id,code,question_text,option_a,option_b,option_c,option_d,option_e,correct_option,explanation,difficulty,source,status) values
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','31000000-0000-0000-0000-000000000001','BIL-001','Hasil dari 18 ÷ 3 × 2 adalah ...','3','6','9','12','18','D','Kerjakan dari kiri ke kanan: 18 ÷ 3 = 6, kemudian 6 × 2 = 12.','easy','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','31000000-0000-0000-0000-000000000001','BIL-002','Nilai dari 2³ + 3² adalah ...','11','13','15','17','19','D','2³ = 8 dan 3² = 9, sehingga jumlahnya 17.','easy','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','31000000-0000-0000-0000-000000000001','BIL-003','Pecahan yang senilai dengan 0,375 adalah ...','1/4','3/8','2/5','5/8','3/4','B','0,375 = 375/1000 = 3/8.','medium','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','31000000-0000-0000-0000-000000000001','BIL-004','FPB dari 48 dan 72 adalah ...','8','12','16','24','36','D','Faktorisasi prima memberi faktor persekutuan terbesar 24.','medium','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','31000000-0000-0000-0000-000000000001','BIL-005','Jika 25% dari suatu bilangan adalah 45, bilangan itu adalah ...','90','120','150','180','225','D','0,25 × n = 45, sehingga n = 45/0,25 = 180.','medium','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','31000000-0000-0000-0000-000000000001','BIL-006','Bilangan terkecil yang habis dibagi 6, 8, dan 15 adalah ...','60','90','120','180','240','C','KPK dari 6, 8, dan 15 adalah 2³ × 3 × 5 = 120.','hard','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000002','31000000-0000-0000-0000-000000000002','ALG-001','Jika 3x + 5 = 20, nilai x adalah ...','3','4','5','6','7','C','3x = 15 sehingga x = 5.','easy','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000002','31000000-0000-0000-0000-000000000002','ALG-002','Bentuk sederhana dari 4a + 3b - 2a + b adalah ...','2a + 2b','2a + 4b','6a + 2b','6a + 4b','2a - 4b','B','Gabungkan suku sejenis: 4a-2a=2a dan 3b+b=4b.','easy','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000002','31000000-0000-0000-0000-000000000002','ALG-003','Akar-akar persamaan x² - 5x + 6 = 0 adalah ...','1 dan 6','2 dan 3','-2 dan -3','-1 dan -6','3 dan 5','B','Faktorkan menjadi (x-2)(x-3)=0.','medium','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000002','31000000-0000-0000-0000-000000000002','ALG-004','Jika f(x)=2x-3, maka f(5) adalah ...','5','7','10','13','17','B','f(5)=2(5)-3=7.','easy','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000002','31000000-0000-0000-0000-000000000002','ALG-005','Penyelesaian dari 2(x-3) > 8 adalah ...','x > 1','x > 4','x > 7','x < 7','x < 1','C','2x-6>8, maka 2x>14 dan x>7.','medium','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000002','31000000-0000-0000-0000-000000000002','ALG-006','Jika x+y=10 dan x-y=4, nilai xy adalah ...','14','18','21','24','28','C','Diperoleh x=7 dan y=3, sehingga xy=21.','hard','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000003','31000000-0000-0000-0000-000000000003','GEO-001','Luas persegi dengan sisi 9 cm adalah ...','18 cm²','36 cm²','72 cm²','81 cm²','90 cm²','D','Luas persegi = s² = 9² = 81 cm².','easy','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000003','31000000-0000-0000-0000-000000000003','GEO-002','Luas segitiga dengan alas 12 cm dan tinggi 8 cm adalah ...','24 cm²','40 cm²','48 cm²','72 cm²','96 cm²','C','Luas = ½ × 12 × 8 = 48 cm².','easy','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000003','31000000-0000-0000-0000-000000000003','GEO-003','Keliling lingkaran berjari-jari 7 cm, dengan π=22/7, adalah ...','22 cm','44 cm','77 cm','88 cm','154 cm','B','Keliling = 2πr = 2 × 22/7 × 7 = 44 cm.','medium','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000003','31000000-0000-0000-0000-000000000003','GEO-004','Panjang diagonal persegi panjang 6 cm × 8 cm adalah ...','7 cm','9 cm','10 cm','12 cm','14 cm','C','Teorema Pythagoras: √(6²+8²)=√100=10.','medium','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000003','31000000-0000-0000-0000-000000000003','GEO-005','Volume kubus dengan rusuk 5 cm adalah ...','25 cm³','75 cm³','100 cm³','125 cm³','150 cm³','D','Volume kubus = s³ = 5³ = 125 cm³.','easy','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000003','31000000-0000-0000-0000-000000000003','GEO-006','Dua segitiga sebangun memiliki perbandingan sisi 2:3. Jika luas segitiga kecil 24 cm², luas segitiga besar adalah ...','36 cm²','48 cm²','54 cm²','72 cm²','81 cm²','C','Perbandingan luas adalah kuadrat sisi, 4:9. Luas besar = 24 × 9/4 = 54.','hard','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000004','31000000-0000-0000-0000-000000000004','STA-001','Rata-rata dari 4, 6, 8, 10, 12 adalah ...','6','7','8','9','10','C','Jumlah data 40 dibagi 5 menghasilkan 8.','easy','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000004','31000000-0000-0000-0000-000000000004','STA-002','Median data 3, 7, 4, 9, 5 adalah ...','4','5','6','7','9','B','Urutkan menjadi 3,4,5,7,9. Nilai tengahnya 5.','easy','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000004','31000000-0000-0000-0000-000000000004','STA-003','Modus data 2, 3, 3, 4, 5, 5, 5, 6 adalah ...','2','3','4','5','6','D','Angka 5 muncul paling banyak, yaitu tiga kali.','easy','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000004','31000000-0000-0000-0000-000000000004','STA-004','Jangkauan data 12, 8, 15, 21, 10 adalah ...','9','11','13','15','21','C','Jangkauan = nilai maksimum - minimum = 21 - 8 = 13.','medium','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000004','31000000-0000-0000-0000-000000000004','STA-005','Rata-rata 6 bilangan adalah 14. Jika lima bilangan pertama berjumlah 65, bilangan keenam adalah ...','14','17','19','21','24','C','Jumlah seluruhnya 6×14=84. Bilangan keenam 84-65=19.','medium','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000004','31000000-0000-0000-0000-000000000004','STA-006','Rata-rata nilai 20 siswa adalah 72. Setelah nilai seorang siswa ditambahkan, rata-rata menjadi 73. Nilai siswa tersebut adalah ...','73','83','88','93','103','D','Jumlah baru 21×73=1533, jumlah lama 20×72=1440, selisih 93.','hard','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000005','31000000-0000-0000-0000-000000000005','PEL-001','Peluang muncul angka genap saat sebuah dadu dilempar adalah ...','1/6','1/3','1/2','2/3','5/6','C','Ada 3 hasil genap dari 6 hasil, sehingga peluang 3/6=1/2.','easy','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000005','31000000-0000-0000-0000-000000000005','PEL-002','Dalam kotak ada 3 bola merah dan 2 bola biru. Peluang mengambil bola biru adalah ...','1/5','2/5','1/2','3/5','4/5','B','Ada 2 bola biru dari total 5 bola.','easy','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000005','31000000-0000-0000-0000-000000000005','PEL-003','Dua koin dilempar. Peluang muncul tepat satu gambar adalah ...','1/4','1/3','1/2','2/3','3/4','C','Ruang sampel: AA, AG, GA, GG. Tepat satu gambar terjadi pada AG dan GA, yaitu 2/4.','medium','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000005','31000000-0000-0000-0000-000000000005','PEL-004','Peluang mengambil kartu As dari satu set kartu remi 52 lembar adalah ...','1/52','1/26','1/13','4/13','1/4','C','Ada 4 kartu As, maka peluangnya 4/52=1/13.','medium','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000005','31000000-0000-0000-0000-000000000005','PEL-005','Peluang tidak muncul bilangan 6 pada sebuah dadu adalah ...','1/6','1/3','1/2','2/3','5/6','E','Lima dari enam sisi bukan angka 6, sehingga peluang 5/6.','easy','Demo','active'),
('20000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000005','31000000-0000-0000-0000-000000000005','PEL-006','Dua dadu dilempar bersamaan. Peluang jumlah mata dadu 7 adalah ...','1/12','1/9','1/6','1/4','1/3','C','Ada 6 pasangan berjumlah 7 dari 36 kemungkinan, jadi 6/36=1/6.','hard','Demo','active')
on conflict(code) do nothing;

-- Tambahan soal demo agar pilihan latihan 5/10/15 dapat langsung diuji pada setiap materi.
with topic_set as (
  select * from (values
    ('30000000-0000-0000-0000-000000000001'::uuid,'BIL','31000000-0000-0000-0000-000000000001'::uuid),
    ('30000000-0000-0000-0000-000000000002'::uuid,'ALG','31000000-0000-0000-0000-000000000002'::uuid),
    ('30000000-0000-0000-0000-000000000003'::uuid,'GEO','31000000-0000-0000-0000-000000000003'::uuid),
    ('30000000-0000-0000-0000-000000000004'::uuid,'STA','31000000-0000-0000-0000-000000000004'::uuid),
    ('30000000-0000-0000-0000-000000000005'::uuid,'PEL','31000000-0000-0000-0000-000000000005'::uuid)
  ) v(topic_id,prefix,subtopic_id)
), generated as (
  select topic_id,prefix,subtopic_id,n,
    case prefix
      when 'BIL' then format('Nilai dari %s² adalah ...',n)
      when 'ALG' then format('Jika x + %s = %s, nilai x adalah ...',n,n*2)
      when 'GEO' then format('Keliling persegi dengan sisi %s cm adalah ...',n)
      when 'STA' then format('Rata-rata dari %s, %s, dan %s adalah ...',n,n+2,n+4)
      else format('Sebuah kotak berisi %s bola merah dan %s bola biru. Peluang mengambil bola merah adalah ...',n,n)
    end question_text,
    case prefix when 'BIL' then (n*n)::text when 'ALG' then n::text when 'GEO' then (4*n)::text when 'STA' then (n+2)::text else '1/2' end answer,
    case prefix when 'BIL' then format('%s² = %s.',n,n*n) when 'ALG' then format('x = %s - %s = %s.',n*2,n,n) when 'GEO' then format('Keliling persegi = 4 × %s = %s cm.',n,4*n) when 'STA' then format('(%s + %s + %s) ÷ 3 = %s.',n,n+2,n+4,n+2) else 'Jumlah bola merah sama dengan bola biru, sehingga peluangnya 1/2.' end explanation
  from topic_set cross join generate_series(7,15) n
)
insert into public.questions(subject_id,topic_id,subtopic_id,code,question_text,option_a,option_b,option_c,option_d,option_e,correct_option,explanation,difficulty,source,status)
select '20000000-0000-0000-0000-000000000001',topic_id,subtopic_id,format('%s-%s',prefix,lpad(n::text,3,'0')),question_text,answer,
  case when prefix='PEL' then '1/3' else ((case prefix when 'BIL' then n*n when 'ALG' then n when 'GEO' then 4*n when 'STA' then n+2 end)+1)::text end,
  case when prefix='PEL' then '2/3' else ((case prefix when 'BIL' then n*n when 'ALG' then n when 'GEO' then 4*n when 'STA' then n+2 end)-1)::text end,
  case when prefix='PEL' then '1/4' else ((case prefix when 'BIL' then n*n when 'ALG' then n when 'GEO' then 4*n when 'STA' then n+2 end)+2)::text end,
  null,'A',explanation,case when n<10 then 'easy'::public.difficulty_level when n<13 then 'medium'::public.difficulty_level else 'hard'::public.difficulty_level end,'Demo tambahan','active'
from generated on conflict(code) do nothing;

insert into public.mini_tryouts(id,name,description,subject_id,question_count,duration_minutes,max_attempts,status) values
('40000000-0000-0000-0000-000000000001','Mini Tryout Matematika 01','Latihan singkat lintas lima materi.','20000000-0000-0000-0000-000000000001',20,30,5,'active') on conflict do nothing;
insert into public.mini_tryout_blueprints(mini_tryout_id,topic_id,question_count) values
('40000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001',4),('40000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000002',4),('40000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000003',4),('40000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000004',4),('40000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000005',4) on conflict do nothing;

insert into public.tryouts(id,name,description,subject_id,question_count,duration_minutes,max_attempts,status) values
('50000000-0000-0000-0000-000000000001','Tryout TKA Matematika 01','Simulasi penuh dengan komposisi seimbang.','20000000-0000-0000-0000-000000000001',30,60,2,'active') on conflict do nothing;
insert into public.tryout_blueprints(tryout_id,topic_id,question_count) values
('50000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001',6),('50000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000002',6),('50000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000003',6),('50000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000004',6),('50000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000005',6) on conflict do nothing;
