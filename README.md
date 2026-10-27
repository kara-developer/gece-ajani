# Gece Ajanı: Uyurken Çalışan Yapay Zeka İş Kuyruğu

Akşam görevleri yazarsın, yatarsın. Gece bilgisayarın sırayla Claude Code veya Codex'e yaptırır. Sabah tek komutla ne bittiğini, ne kaldığını görürsün.
**Her çıktı taslaktır. Kabul ya da ret sende.**

Ben tek kişilik şirketimde ağır okuma/özetleme/test yazma işlerini geceye bırakıyorum. Bu repo o düzenin genel, kopyalanabilir hali: tek dosya Python (`gece`), bağımlılık yok.

---

## Neden "sadece bir döngü" değil?

`for görev in görevler: claude -p ...` yazmak 5 dakika sürer. Gece 3'te bozulan şeyler yüzünden uzun bir betik gerekir:

- Aynı anda çok iş açınca bilgisayar kilitlenir → **işçi sınırı (en fazla 2) + yük kontrolü + işler arası mola**
- Kota/limit dolunca iş yarıda kalır → **limiti anlar, bekler, aynı işe devam eder**
- Bir iş sonsuza kadar takılır → **iş başına zaman aşımı, süreç grubu öldürülür**
- Sabah çıktıya körü körüne güvenilir → **kabul ölçütü olmadan iş kuyruğa girmez**, otomatik kontrol, taslak/kabul/ret akışı
- Ajan yanlış klasöre yazar → **salt-okunur varsayılan; yazarsa klasörün kopyasında yazar**, orijinale dokunmaz

---

## İçinde ne var

```
gece-ajani/
├── gece                      ← asıl araç (python3, standart kütüphane)
├── ornek-ajan.sh             ← sahte ajan: kota harcamadan denemek için
├── test.sh                   ← uçtan uca test (sahte ajanla)
├── ornekler/
│   ├── sablon-brief.md       ← boş görev şablonu
│   ├── rakip-ozet.md         ← örnek 1: salt-okunur özet işi
│   ├── test-yaz.md           ← örnek 2: kod için test yazma işi
│   ├── girdi-rakip/          ← örnek 1'in girdisi
│   └── girdi-kod/            ← örnek 2'nin girdisi
└── zamanlama/
    ├── gece-ajani.plist.ornek  ← macOS (launchd)
    └── cron.ornek              ← Linux (cron)
```

Çalışırken `is-kutusu/` oluşur (git'e girmez): her iş için `brief.md`, `log.txt`, `durum.json`, `cikti/`.

---

## Kurulum (10 dk)

**1. Klasörü al**
```bash
git clone https://github.com/kara-developer/gece-ajani ~/gece-ajani && cd ~/gece-ajani
```
**2. Sağlamasını yap** (ajan çağırmaz, kota harcamaz)
```bash
./test.sh        # sonunda: TUM TESTLER GECTI
./gece doctor    # claude / codex kurulu mu, makine yükü kaç
```
**3. İlk görevi yaz.** `ornekler/sablon-brief.md`'yi kopyala ya da `./gece sablon > is.md`.
Dört bölümün hepsi dolu olmak zorunda; boşsa `gece ekle` reddeder.

**4. Kuyruğa koy, kısa bir gerçek deneme yap**
```bash
./gece ekle is.md
./gece calistir --sure 600    # 10 dk'lık deneme; bittiğinde yeni iş başlamaz
./gece ozet
```
**5. Zamanla.** macOS: `zamanlama/gece-ajani.plist.ornek`, Linux: `zamanlama/cron.ornek`. Dosyanın başındaki açıklamayı oku.

**En kolayı:** `PROMPT.md`'yi yapay zekana ver, kurulumu seninle adım adım o yapsın.

---

## Görev (BRIEF) nasıl yazılır

```markdown
---
ad: rakip-ozet
ajan: claude          # claude | codex | ozel
mod: oku              # oku = salt-okunur | yaz = klasörün KOPYASINDA çalışır
klasor: girdi-rakip   # ajanın göreceği tek klasör (brief dosyasına göre)
sure: 20              # dakika
kontrol: test "$(grep -c '^## ' sonuc.md)" -ge 10    # isteğe bağlı otomatik kontrol
---
## Amaç            → sabah elimde ne olmalı (tek cümle)
## Girdiler        → ajan hangi dosyaları okuyacak, başka kaynak var mı
## Kabul ölçütü    → sayılabilir maddeler ("tam 10 bölüm", "her biri ≤3 cümle")
## Yasaklar        → bu işe özel; "dışarıya gönderme" sisteme zaten gömülü
```

En çok değer **Kabul ölçütü**'nde. "İyi bir özet yaz" ölçüt değildir; "tam 10 bölüm, her biri en fazla 3 cümle, girdide olmayan sayı yok" ölçüttür. Sabah çıktıyı bununla tartarsın, ajan da kendini bununla tartar.

İki hazır örnek: `ornekler/rakip-ozet.md` (salt-okunur) ve `ornekler/test-yaz.md` (yazar modu).

> Instagram'a otomatik bağlanma yok: rakip örneğinde gönderi metinlerini sen yapıştırıyorsun. Bilerek böyle; giriş yapılmış hesaba gece ajan salmak kötü fikir.

---

## Komutlar

| Komut | Ne yapar |
|---|---|
| `gece ekle BRIEF.md` | Doğrular, kuyruğa alır (`001-ad` gibi bir kimlik verir) |
| `gece calistir [--sure SN]` | Sırayla çalıştırır. `--sure` dolunca yeni iş başlamaz |
| **`gece ozet`** | Sabah tek ekran: taslaklar / kalanlar / sorunlular / kapananlar |
| `gece goster ID` | Sonucu, diff'i (yazar modunda), hata varsa log'u gösterir. `ID` yerine `1` de yeter |
| `gece kabul ID [--not ..]` | Taslağı kabul olarak işaretler |
| `gece red ID --not "neden"` | Reddeder (gerekçe zorunlu) |
| `gece tekrar ID` | Hata/zaman aşımı/red olan işi yeniden kuyruğa alır |
| `gece liste` / `doctor` / `sablon` | Kuyruk, sağlık kontrolü, boş şablon |

İş durumları: `bekliyor → calisiyor → taslak → kabul | red`; yan yollar: `limit_bekliyor`, `hata`, `zaman_asimi`.

---

## Ayarlar (ortam değişkenleri)

| Değişken | Varsayılan | Anlamı |
|---|---|---|
| `GECE_ISCI` | 1 | Eşzamanlı iş sayısı. **Sert tavan 2**, fazlası kırpılır |
| `GECE_MOLA` | 120 sn | Bir işçinin işleri arasındaki mola |
| `GECE_YUK_ESIK` | 5.0 | 1 dk yük ortalaması bunun üstündeyse yeni iş başlamaz |
| `GECE_YUK_BEKLE` | 600 sn | Yük düşmesini bu kadar bekle, düşmezse çalıştırmayı durdur (işler kuyrukta kalır) |
| `GECE_SURE` | 8 saat | Toplam çalışma süresi (`--sure` ile geçersiz kılınır) |
| `GECE_LIMIT_BEKLE` | 1800 sn | Limit/kota sinyalinde bekleme; sonra **aynı işi** yeniden dener |
| `GECE_LIMIT_DENEME` | 8 | Bir iş için en fazla bu kadar limit beklemesi |
| `GECE_KOPYA_MB` | 500 | Yazar modunda kopyalanacak klasörün üst sınırı |
| `GECE_AJAN_KOMUT` | yok | Ajanı kendi komutunla değiştir (prompt stdin'den gelir). Deneme ve başka araçlar için |
| `GECE_CLAUDE`, `GECE_CODEX` | claude, codex | Çalıştırılabilir dosyanın yolu |
| `GECE_DIZIN` | `./is-kutusu` | Kuyruk ve çıktıların klasörü |

**Neden bu varsayılanlar?** 2 işçi, 2 dk mola ve yük eşiği 5: ortalama bir dizüstüde sana hâlâ kullanılabilir bir makine bırakır. Bulutta çalışan modellerde işçi sayısını artırmak çoğu zaman hızı değil, kota yanmasını ve ısıyı artırır. Kendi makinende `gece doctor` ile yükü izleyip eşiği ayarla.

---

## Güvenlik (okumadan kurma)

Gece ajan gözetimsizdir. Bu yüzden varsayılanlar sıkı:

1. **Salt-okunur varsayılan.** `mod: oku` iken Claude'a yalnız `Read, Glob, Grep` araçları, Codex'e `read-only` sandbox verilir. Hiçbir şey yazamaz, komut çalıştıramaz.
2. **Yazar modu orijinale dokunmaz.** `mod: yaz` klasörün iki kopyasını alır (`a` temiz, `b` ajan çalışma alanı). Ajan `b`'de çalışır, sen sabah `degisiklik.diff`'i okur, beğenirsen `patch` ile uygularsın. Kabul etmek bile otomatik uygulamaz.
3. **Çalışma klasörü sınırı.** `klasor` tek klasördür; kök dizin ve ev dizini reddedilir. `.git`, `node_modules`, `.env*` kopyaya girmez. Ajan `-C`/çalışma dizini olarak yalnız bu klasörde başlar.
4. **Gece dışa hiçbir şey yok.** Her isteme gömülü kural: e-posta, mesaj, yayın, ödeme, form, `git push`, deploy yok; brief istese bile yapılmaz, sonuca "yapmadım: ne" yazılır. Bu bir **istem kuralıdır, teknik kilit değil**; asıl kilit araç izinleridir (salt-okunur modda yazma/komut aracı hiç yok). Gece dışa işlem yapan görevi kuyruğa koyma; sabah kendi elinle yap.
5. **Tehlikeli bayrak yok.** `--dangerously-skip-permissions` ve benzerleri kodda kullanılmaz. Ekstra araç gerekiyorsa brief'e açıkça yaz (`izinler: Bash(npm test:*)`) ve bunu bilerek ver.
6. **Gizli bilgi.** Anahtar/şifre/token'ı brief'e, girdiye, loga yazma. Ajan süreci senin ortam değişkenlerini görür (kimlik doğrulaması için gerekli); bu yüzden gece koşan kullanıcıda gereksiz gizli anahtar tutma.
7. **Tek çalıştırma.** Kilit dosyası aynı anda ikinci `calistir`'ı engeller (cron + elle başlatma çakışmaz).

---

## Zamanlama

- **macOS:** `zamanlama/gece-ajani.plist.ornek`. `caffeinate -i` ile sarılı; kapak kapalıyken Mac uyur ve iş durur. Prize tak, kapağı açık bırak.
- **Linux:** `zamanlama/cron.ornek`. cron'un PATH'i boştur, `claude`/`codex` klasörünü PATH satırına yaz (sık yapılan hata).
- Her ikisi de `--sure 21600` (6 saat) kullanır: bu süreden sonra yeni iş başlamaz. Çalışan iş kendi zaman aşımına kadar sürer.
- Gece çalışırken bilgisayarı ben de kullanırsam diye yük eşiği devrede: makine meşgulse iş başlamaz.

---

## Tuzaklar ve çözümleri

| Kaynak | Ne oldu / ne olur | Çözüm |
|---|---|---|
| Yaşadık | Bir gece işinde 8 paralel işçi dizüstünü kilitledi (yük ~12, sonra 17'ye çıktı, makine ısındı) | İşçi tavanı 2, işler arası mola, yük eşiği aşılınca iş başlatma |
| Yaşadık | Sabah çıktıyı okurken işçinin önerisi bizim koyduğumuz kurala aykırıydı; kural brief'te yazmıyordu | Brief'te **Kabul ölçütü ve Yasaklar zorunlu**; çıktı taslak, kabul insanda |
| Yaşadık | Brief'te anılan bir dosya girdiye konmayınca işçi "doğrulanamadı" deyip çıktı | `Girdiler` bölümü ajanın okuyacağı her dosyayı saymalı; sabah `goster` ile eksik girdiyi gör, `tekrar` |
| Yaşadık | Başsız (`-p`) modda onay isteyen komutlar sessizce reddedildi; iş "bitti" görünüp o adım hiç çalışmadı | Ekstra araç gerekiyorsa `izinler:` ile açıkça ver; `log.txt`'yi oku; kabul ölçütüne "şu komut geçecek" yaz |
| Yaşadık | Limit dolunca gece işini ancak limit açılınca başlatabildik; elle beklemek gerekti | Limit sinyalinde bekle-devam (aşağıda) ve sonraki geceye bırak |
| Tasarım | Limit işin ortasında dolarsa iş yarıda kalır ve sonraki görevler de tek tek patlar | Çıktıda limit/kota/429 sinyali görülürse iş `limit_bekliyor` olur, `GECE_LIMIT_BEKLE` sonra **aynı iş** yeniden denenir. Süre bitmişse iş `bekliyor` kalır, ertesi gece devam eder |
| Tasarım | Bir iş sonsuza takılır, sıradaki 10 iş hiç başlamaz | İş başına `sure:`; aşınca süreç grubu önce SIGTERM, sonra SIGKILL; iş `zaman_asimi`, sıra devam eder |
| Tasarım | Ajan klasörü bozar | Yazar modunda yalnız kopyaya yazar; diff elle uygulanır |
| Tasarım | Çalıştırma gece yarısı çöker, iş `calisiyor` takılı kalır | Sonraki `calistir` yarım işleri `bekliyor`a geri alır |
| Tasarım | Cron ve elle başlatma aynı anda çalışır | Kilit dosyası; ikinci çalıştırma açıkça reddedilir |
| Tasarım | Ajan boş ya da sadece hata dolu çıktı verip "başarılı" sayılır | Çıkış kodu ≠ 0 ya da boş çıktı `hata`; `kontrol:` komutu geçmezse özette `KALDI` yazar |

"Yaşadık" satırları gerçek olaylardan geldi; "Tasarım" satırları bu araçta alınmış önlemler, öncelikle kendi bilgisayarında test et.

---

## Dürüst sınırlar

- Ajan komut satırı bayrakları (Claude Code, Codex) sürümler arası değişebilir. `./gece doctor` ve `GECE_AJAN_KOMUT` bunun için var; test paketi sahte ajanla **kuyruk mantığını** doğrular, gerçek ajanın kalitesini değil.
- Limit algılama çıktıdaki ifadelere bakar (`usage limit`, `rate limit`, `429`, `quota`...). Araç farklı bir mesaj basıyorsa `LIMIT_RE`'ye ekle (`gece` dosyasının başı).
- Zaman aşımı yalnız ajan sürecini ve alt süreçlerini keser; ajanın bulut tarafındaki kotası harcanmış olabilir.
- Bu bir "otopilot" değil, **gece vardiyası**: sabah incelemeyi atlarsan değer sıfırlanır.

---

**Kara Developer** · Instagram: [@kara.developer](https://instagram.com/kara.developer). Tek kişilik şirketimi AI ajanlarıyla yönetiyorum, çalışanı paylaşıyorum.
Lisans: MIT
