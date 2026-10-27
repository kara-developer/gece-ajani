# Yapay zekana ver (Claude Code / Codex / Gemini CLI)

```
Bu klasör bir "gece iş kuyruğu" (gece betiği, ornekler/, zamanlama/, README.md, test.sh).
Önce README.md'yi baştan sona oku. Sonra benimle adım adım kur:

1. `./test.sh` çalıştır ve çıktıyı birlikte oku; "TUM TESTLER GECTI" görmeden ilerleme.
2. `./gece doctor` çalıştır. Hangi ajanların (claude / codex) kurulu olduğunu ve makine yükünü bana açıkla.
3. Bilgisayarım Mac mi Linux mu, dizüstü mü sunucu mu, sor. Ona göre zamanlama dosyasını (zamanlama/) benimle uyarla;
   benim yerime kurma: ne yapacağını göster, ben onaylayınca kur. Mac dizüstüyse uyku/kapak/prize takılı olma konusunu anlat.
4. İlk görevi birlikte seçelim: bana "gece, ben uyurken bilgisayarın benim için yapmasını istediğim iş ne?" diye sor.
   Küçük, tek klasörle sınırlı, sonucu gözle kontrol edebileceğim bir iş seçtir (ilk gece büyük iş yok).
   ornekler/sablon-brief.md ile BRIEF'i yaz; ÖZELLİKLE "Kabul ölçütü"nü sayılabilir maddelerle yazdır ve "Yasaklar"ı boş bırakma.
   Varsayılan mod `oku` olsun; `yaz` istersem nedenini sor.
5. `./gece ekle BRIEF.md` ile kuyruğa koy, ardından GERÇEK ajanla kısa bir deneme yap:
   `GECE_ISCI=1 ./gece calistir --sure 600`. Çıktıyı `./gece goster 1` ile birlikte inceleyelim, kabul ölçütüne göre puanla.
6. Zamanlamayı kur, ertesi sabah `./gece ozet` ile sonucu birlikte değerlendirelim.
Kurallar: ajanlara geniş yetki verme (ev dizini, kök dizin, --dangerously-skip-permissions yok). Anahtar/şifre/token
asla brief'e, loga ya da sohbete yazılmaz. Gece dışarıya mesaj, ödeme, yayın yapan bir görevi kuyruğa koyma;
istersem bunun sabah benim elimle yapılacağını hatırlat. Çıktıyı doğrulamadan "iş bitti" deme.
```
