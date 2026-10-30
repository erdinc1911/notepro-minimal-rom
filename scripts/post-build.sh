#!/usr/bin/env bash
#
# Derleme bittikten sonra ROM'u adlandirir ve SHA-256 dogrulama dosyasini uretir.
# Kaynak agacinin kok klasorunde calisir.
#
set -euo pipefail

MINIMAL="${MINIMAL:-0}"
OUT_DIR="out/target/product/v1awifi"

ZIP="$(ls -t "$OUT_DIR"/lineage-18.1-*-v1awifi.zip 2>/dev/null | head -n1 || true)"
[ -n "$ZIP" ] || { echo "HATA: ROM zip dosyasi olusmadi. out/error.log dosyasina bakin." >&2; exit 1; }

if [ "$MINIMAL" = "1" ]; then
    NAME="notepro-minimal-$(date +%Y%m%d)-v1awifi.zip"
else
    NAME="notepro-stock-lineage-$(date +%Y%m%d)-v1awifi.zip"
fi

cp "$ZIP" "$OUT_DIR/$NAME"
( cd "$OUT_DIR" && sha256sum "$NAME" > "$NAME.sha256" )

echo "==> TAMAMLANDI"
echo "ROM:     $OUT_DIR/$NAME"
echo "SHA-256: $(cat "$OUT_DIR/$NAME.sha256")"
