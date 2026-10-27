#!/usr/bin/env bash
# Sahte ajanla uctan uca test. Kota harcamaz, gercek ajan gerekmez.
set -u
AYRI="$(cd "$(dirname "$0")" && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
export GECE_DIZIN="$T/kutu" GECE_AJAN_KOMUT="$AYRI/ornek-ajan.sh" GECE_MOLA=0 GECE_LIMIT_BEKLE=2 SAHTE_KAYIT="$T/kayit.txt" SAHTE_SURE=1
G="$AYRI/gece"; HATA=0
dogru() { if [[ "$2" == *"$3"* ]]; then echo "  ok   $1"; else echo "  FAIL $1 (aranan: $3)"; HATA=1; fi; }
brief() { # ad mod ekstra-govde [sure]
  mkdir -p "$T/k"; echo "x" > "$T/k/dosya.txt"
  cat > "$T/$1.md" <<B
---
ad: $1
mod: $2
klasor: k
sure: ${4:-1}
kontrol: test -s sonuc.md
---
## Amaç
test $3
## Girdiler
dosya.txt
## Kabul ölçütü
sonuc.md bos degil
## Yasaklar
dis dunyaya gonderme
B
}

echo "1) Dogrulama: eksik brief reddedilir"
printf -- '---\nad: bos\n---\n## Amaç\nx\n' > "$T/bos.md"
dogru "eksik bolum" "$("$G" ekle "$T/bos.md" 2>&1)" "ALINMADI"
dogru "ev dizini yasak" "$(printf -- '---\nklasor: ~\n---\n## Amaç\nx\n## Girdiler\nx\n## Kabul ölçütü\nx\n## Yasaklar\nx\n' > "$T/ev.md"; "$G" ekle "$T/ev.md" 2>&1)" "ev dizini"

echo "2) Akis: ekle -> calistir -> ozet -> kabul"
brief oku1 oku "normal"; brief yaz1 yaz "normal"
"$G" ekle "$T/oku1.md" >/dev/null; "$G" ekle "$T/yaz1.md" >/dev/null
C="$("$G" calistir --sure 60 2>&1)"
dogru "iki is islendi" "$C" "2 is islendi"
O="$("$G" ozet)"
dogru "ozet taslak sayar" "$O" "TASLAK - inceleme bekliyor (2)"
dogru "kontrol gecti" "$O" "kontrol:gecti"
dogru "yaz modu diff uretti" "$(cat "$T"/kutu/isler/002-*/cikti/degisiklik.diff)" "test_sahte.py"
dogru "orijinal klasor degismedi" "$(ls "$T/k")" "dosya.txt"
[[ ! -e "$T/k/test_sahte.py" ]] && echo "  ok   orijinalde test_sahte.py yok" || { echo "  FAIL orijinal kirlendi"; HATA=1; }
dogru "kabul" "$("$G" kabul 1 --not iyi)" "kabul edildi"
dogru "red notsuz reddedilir" "$("$G" red 2 2>&1)" "gerekce"
"$G" red 2 --not "yetersiz" >/dev/null
dogru "ozet kapananlari sayar" "$("$G" ozet)" "1 kabul, 1 red"

echo "3) Limit: bekle ve devam"
brief limit oku "SAHTE-LIMIT"; "$G" ekle "$T/limit.md" >/dev/null
C="$("$G" calistir --sure 60 2>&1)"
dogru "limit sonrasi taslak" "$("$G" ozet)" "003-limit"
dogru "limit loglandi" "$(cat "$T"/kutu/isler/003-*/log.txt)" "limit/kota sinyali"
dogru "ikinci denemede bitti" "$("$G" goster 3)" "[taslak]"

echo "4) Zaman asimi + hata"
brief uyu oku "SAHTE-UYU" 0.03; brief hatali oku "SAHTE-HATA"
"$G" ekle "$T/uyu.md" >/dev/null; "$G" ekle "$T/hatali.md" >/dev/null
START=$(date +%s); "$G" calistir --sure 120 >/dev/null 2>&1; GEC=$(( $(date +%s) - START ))
O="$("$G" ozet)"
dogru "zaman asimi" "$O" "ZAMAN ASIMI"
dogru "hata yakalandi" "$O" "HATA"
[[ $GEC -lt 30 ]] && echo "  ok   uyuyan ajan 60 sn degil ${GEC} sn'de kesildi" || { echo "  FAIL timeout calismadi ($GEC sn)"; HATA=1; }

echo "5) Isci siniri (5 istendi -> en fazla 2) + mola"
rm -rf "$T/kutu"; : > "$T/kayit.txt"
for n in 1 2 3 4; do brief "p$n" oku "paralel"; "$G" ekle "$T/p$n.md" >/dev/null; done
C="$(GECE_ISCI=5 SAHTE_SURE=1.5 "$G" calistir --sure 120 2>&1)"
dogru "uyari verdi" "$C" "tavan 2"
MAX=$(python3 - "$T/kayit.txt" <<'PY'
import sys
o=0;m=0
for l in sorted(open(sys.argv[1]).read().splitlines()):
    o+= 1 if "basladi" in l else -1
    m=max(m,o)
print(m)
PY
)
[[ "$MAX" == "2" ]] && echo "  ok   en fazla 2 is ayni anda (olculen: $MAX)" || { echo "  FAIL eszamanli: $MAX"; HATA=1; }
rm -rf "$T/kutu"; for n in 1 2; do "$G" ekle "$T/p$n.md" >/dev/null; done
S=$(date +%s); GECE_MOLA=3 SAHTE_SURE=0 "$G" calistir --sure 120 >/dev/null 2>&1; GEC=$(( $(date +%s) - S ))
[[ $GEC -ge 3 ]] && echo "  ok   isler arasi mola uygulandi (${GEC} sn)" || { echo "  FAIL mola yok (${GEC} sn)"; HATA=1; }

echo "6) Makine yuku yuksekse baslamaz"
rm -rf "$T/kutu"; "$G" ekle "$T/p1.md" >/dev/null
C="$(GECE_YUK_ESIK=0 GECE_YUK_BEKLE=1 "$G" calistir --sure 60 2>&1)"
dogru "yuk nedeniyle durdu" "$C" "makine yuku"
dogru "is kuyrukta kaldi" "$("$G" ozet)" "KALDI - henuz calismadi / yarida (1)"

echo "7) Sure dolunca yeni is baslamaz"
rm -rf "$T/kutu"; for n in 1 2 3; do "$G" ekle "$T/p$n.md" >/dev/null; done
GECE_MOLA=0 SAHTE_SURE=2 "$G" calistir --sure 3 >/dev/null 2>&1
dogru "en az bir is kuyrukta kaldi" "$("$G" ozet)" "[BEKLIYOR]"

echo; [[ $HATA == 0 ]] && echo "TUM TESTLER GECTI" || { echo "BAZI TESTLER KALDI"; exit 1; }
