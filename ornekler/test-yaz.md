---
ad: fiyat-testleri
ajan: claude
mod: yaz
klasor: girdi-kod
sure: 30
kontrol: cd "$CALISMA_KLASORU" && python3 -m unittest discover -s . -p 'test_*.py'
---

## Amaç
`fiyat.py` içindeki fonksiyonlar için `unittest` ile test dosyası yaz; sabah testlerin geçtiğini görmek istiyorum.

## Girdiler
- `fiyat.py`: üç fonksiyon (`indirim_uygula`, `kdv_ekle`, `toplam`). Başka dosya yok.
- Test dosyasını aynı klasöre `test_fiyat.py` adıyla yaz.

## Kabul ölçütü
- `python3 -m unittest discover -s . -p 'test_*.py'` komutu hatasız geçecek.
- Her fonksiyon için en az 3 test: normal durum, sınır değer (0, yüzde 100), geçersiz girdi (negatif, yanlış tür).
- `fiyat.py` DEĞİŞMEYECEK. Bir hata bulursan düzeltme, sonuç özetinde "BULGU:" satırıyla yaz.
- Dış kütüphane yok (yalnız standart kütüphane).

## Yasaklar
- `fiyat.py` dahil mevcut dosyaları değiştirme; yalnız yeni test dosyası ekle.
- Ağ erişimi, paket kurma, dış servis çağrısı yok.
