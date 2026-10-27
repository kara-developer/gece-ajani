#!/usr/bin/env bash
# Sahte ajan: gece'yi gercek bir yapay zeka (kota harcamadan) denemek icin.
# Kullanim:  export GECE_AJAN_KOMUT="$PWD/ornek-ajan.sh"
# Prompt stdin'den gelir. Brief icindeki anahtar kelimeye gore davranir:
#   SAHTE-LIMIT  -> ilk denemede "usage limit reached" der, ikinci denemede basarir
#   SAHTE-UYU    -> 60 sn uyur (zaman asimi testi)
#   SAHTE-HATA   -> hata koduyla cikar
set -u
PROMPT="$(cat)"
if [[ "$PROMPT" == *SAHTE-LIMIT* && ! -f "$GECE_IS_DIZIN/.limit-goruldu" ]]; then
  touch "$GECE_IS_DIZIN/.limit-goruldu"
  echo "Claude usage limit reached. Your limit will reset at 03:00." >&2
  exit 1
fi
[[ "$PROMPT" == *SAHTE-UYU* ]] && sleep 60
[[ "$PROMPT" == *SAHTE-HATA* ]] && { echo "bir seyler ters gitti" >&2; exit 2; }
echo "$(date +%T) $GECE_IS_ID basladi" >> "${SAHTE_KAYIT:-/dev/null}"
sleep "${SAHTE_SURE:-1}"
if [[ "$GECE_MOD" == "yaz" ]]; then
  printf 'import unittest\n\nclass T(unittest.TestCase):\n    def test_ok(self):\n        self.assertTrue(True)\n\nif __name__ == "__main__":\n    unittest.main()\n' > "$CALISMA_KLASORU/test_sahte.py"
fi
printf '## 1. Sahte sonuc\nBu cikti %s modunda sahte ajan tarafindan uretildi.\n' "$GECE_MOD"
echo "$(date +%T) $GECE_IS_ID bitti" >> "${SAHTE_KAYIT:-/dev/null}"
