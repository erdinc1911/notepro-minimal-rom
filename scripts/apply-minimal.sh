#!/usr/bin/env bash
#
# Minimal katmani ac/kapat.
# Kaynak agacinin kok klasorunde, repo sync'ten SONRA, derlemeden ONCE calisir.
#   MINIMAL=0  -> degistirilmemis LineageOS 18.1
#   MINIMAL=1  -> vendor/minimal/config/minimal.mk devreye girer
#
set -euo pipefail

MINIMAL="${MINIMAL:-0}"
DEVICE_MK="device/samsung/v1awifi/device.mk"
HOOK='$(call inherit-product-if-exists, vendor/minimal/config/minimal.mk)'

[ -f "$DEVICE_MK" ] || { echo "HATA: $DEVICE_MK yok (repo sync basarisiz?)" >&2; exit 1; }

# Her calistirmada temiz baslangic: onceki eklemeyi kaldir
grep -vF "$HOOK" "$DEVICE_MK" | grep -vF "# Note Pro Minimal ROM" > "$DEVICE_MK.tmp" || true
mv "$DEVICE_MK.tmp" "$DEVICE_MK"

if [ "$MINIMAL" = "1" ]; then
    printf '\n# Note Pro Minimal ROM\n%s\n' "$HOOK" >> "$DEVICE_MK"
    echo "==> Minimal katman ACIK"
else
    echo "==> Minimal katman KAPALI (degistirilmemis LineageOS 18.1)"
fi
