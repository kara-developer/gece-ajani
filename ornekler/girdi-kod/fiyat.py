"""Küçük fiyat hesaplama modülü (örnek)."""


def indirim_uygula(fiyat, yuzde):
    """fiyat'tan yüzde kadar indirim düşer. yuzde 0-100 arası olmalı."""
    if not isinstance(fiyat, (int, float)) or not isinstance(yuzde, (int, float)):
        raise TypeError("sayı bekleniyor")
    if fiyat < 0 or not 0 <= yuzde <= 100:
        raise ValueError("geçersiz değer")
    return round(fiyat * (1 - yuzde / 100), 2)


def kdv_ekle(fiyat, oran=20):
    """fiyat'a KDV oranını (yüzde) ekler."""
    if not isinstance(fiyat, (int, float)):
        raise TypeError("sayı bekleniyor")
    if fiyat < 0 or oran < 0:
        raise ValueError("geçersiz değer")
    return round(fiyat * (1 + oran / 100), 2)


def toplam(kalemler):
    """[(fiyat, adet), ...] listesinin toplamı."""
    return round(sum(f * a for f, a in kalemler), 2)
