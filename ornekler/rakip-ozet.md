---
ad: rakip-ozet
ajan: claude
mod: oku
klasor: girdi-rakip
sure: 20
kontrol: test "$(grep -c '^## ' sonuc.md)" -ge 10
---

## Amaç
Rakibimin son 10 Instagram gönderisini özetleyip hangi konuların ve hangi açılış cümlelerinin işlediğini çıkar; sabah bir içerik fikir listesi olarak okuyacağım.

## Girdiler
- `gonderiler.txt`: rakibin son 10 gönderisinin metni, ben elle yapıştırdım. Gönderiler `### 1.` ... `### 10.` başlıklarıyla ayrılmış; her birinde beğeni ve yorum sayısı var.
- Başka kaynak yok. Instagram'a bağlanma, internette arama yapma.

## Kabul ölçütü
- Sonuç dosyasında tam 10 adet `## N. <kısa başlık>` bölümü olacak (her gönderi için bir tane).
- Her bölüm en fazla 3 cümle: konu, açılış cümlesinin tekniği, etkileşim sayıları.
- En sonda `## Örüntüler` bölümü: 3 madde, her madde hangi gönderi numaralarına dayandığını yazsın.
- `## Bana fikirler` bölümü: bu örüntülerden çıkan 5 içerik fikri, her biri tek satır.
- Girdide olmayan sayı ya da olgu yok. Emin olmadığın yere "belirsiz" yaz.

## Yasaklar
- Rakibe, hiç kimseye mesaj, yorum, beğeni gönderme.
- Metinleri kopyalayıp "bizim içerik" gibi sunma; yalnız analiz.
- Dosya değiştirme (salt-okunur).
