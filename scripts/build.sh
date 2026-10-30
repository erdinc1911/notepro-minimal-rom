#!/usr/bin/env bash
#
# Note Pro 12.2 (SM-P900 / v1awifi) - LineageOS 18.1 derleme betigi
#
# Bir Linux x86-64 derleme sunucusunda (crave.io veya yeterli guclu bir
# bilgisayar) calistirilir. MagicPad 2 veya Windows bilgisayarda CALISMAZ.
#
# Kullanim:
#   MINIMAL=0 bash build.sh    # Asama 2: degistirilmemis LineageOS 18.1 (varsayilan)
#   MINIMAL=1 bash build.sh    # Asama 4: sadelestirilmis ROM
#
# Ortam degiskenleri:
#   WORKDIR     Kaynak kodun indirilecegi klasor  (varsayilan: $HOME/android/lineage)
#   MINIMAL     0 = sade LineageOS, 1 = minimal katman acik (varsayilan: 0)
#   BUILD_TYPE  userdebug veya user                (varsayilan: userdebug)
#   SKIP_SYNC   1 ise repo sync atlanir            (varsayilan: 0)
#
set -euo pipefail

REPO_OWNER="erdinc1911"
REPO_NAME="notepro-minimal-rom"
RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main"

WORKDIR="${WORKDIR:-$HOME/android/lineage}"
MINIMAL="${MINIMAL:-0}"
BUILD_TYPE="${BUILD_TYPE:-userdebug}"
SKIP_SYNC="${SKIP_SYNC:-0}"
JOBS="$(nproc)"

log() { printf '\n==> %s\n' "$*"; }
die() { printf '\nHATA: %s\n' "$*" >&2; exit 1; }

# --- 0. On kontroller ------------------------------------------------------
[ "$(uname -m)" = "x86_64" ] || die "Bu betik yalnizca x86-64 Linux'ta calisir."
command -v repo >/dev/null || die "'repo' araci bulunamadi. Kurulum: https://source.android.com/docs/setup/download"
command -v git  >/dev/null || die "'git' bulunamadi."

mem_gb=$(awk '/MemTotal/ {printf "%d", $2/1024/1024}' /proc/meminfo)
log "Sunucu: ${JOBS} cekirdek, ${mem_gb} GB RAM"
[ "$mem_gb" -ge 16 ] || echo "UYARI: 16 GB'tan az RAM. Derleme cok yavas olabilir veya bellek yetersizliginden durabilir."

mkdir -p "$WORKDIR"
cd "$WORKDIR"

# --- 1. Kaynak kodu indir --------------------------------------------------
if [ ! -d .repo ]; then
    log "LineageOS 18.1 kaynak deposu hazirlaniyor"
    repo init -u https://github.com/LineageOS/android.git -b lineage-18.1 --depth=1
fi

log "Cihaz manifesti yerlestiriliyor"
mkdir -p .repo/local_manifests
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/../manifests/v1awifi.xml" ]; then
    cp "$SCRIPT_DIR/../manifests/v1awifi.xml" .repo/local_manifests/v1awifi.xml
else
    curl -fsSL "$RAW_BASE/manifests/v1awifi.xml" -o .repo/local_manifests/v1awifi.xml
fi

if [ "$SKIP_SYNC" != "1" ]; then
    log "Kaynak kod esitleniyor (ilk seferde uzun surer)"
    repo sync -c -j"$JOBS" --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune
fi

# --- 2. Minimal katmani ac/kapat --------------------------------------------
DEVICE_MK="device/samsung/v1awifi/device.mk"
HOOK='$(call inherit-product-if-exists, vendor/minimal/config/minimal.mk)'
[ -f "$DEVICE_MK" ] || die "$DEVICE_MK bulunamadi; repo sync basarisiz olmus olabilir."

# Her calistirmada temiz baslangic: onceki eklemeyi kaldir
grep -vF "$HOOK" "$DEVICE_MK" > "$DEVICE_MK.tmp" && mv "$DEVICE_MK.tmp" "$DEVICE_MK"

if [ "$MINIMAL" = "1" ]; then
    log "Minimal katman ACIK"
    printf '\n# Note Pro Minimal ROM\n%s\n' "$HOOK" >> "$DEVICE_MK"
else
    log "Minimal katman KAPALI (degistirilmemis LineageOS 18.1)"
fi

# --- 3. Derle ----------------------------------------------------------------
if command -v ccache >/dev/null; then
    export USE_CCACHE=1
    export CCACHE_EXEC="$(command -v ccache)"
    ccache -M 50G >/dev/null 2>&1 || true
fi
export LC_ALL=C

log "Derleme basliyor: lineage_v1awifi-${BUILD_TYPE}"
# shellcheck disable=SC1091
set +u
source build/envsetup.sh
lunch "lineage_v1awifi-${BUILD_TYPE}"
set -u
mka bacon -j"$JOBS"

# --- 4. Ciktilari dogrula ------------------------------------------------------
OUT_DIR="out/target/product/v1awifi"
ZIP="$(ls -t "$OUT_DIR"/lineage-18.1-*-v1awifi.zip 2>/dev/null | head -n1 || true)"
[ -n "$ZIP" ] || die "ROM zip dosyasi olusmadi. Hata icin out/error.log dosyasina bakin."

if [ "$MINIMAL" = "1" ]; then
    FINAL="$OUT_DIR/notepro-minimal-$(date +%Y%m%d)-v1awifi.zip"
else
    FINAL="$OUT_DIR/notepro-stock-lineage-$(date +%Y%m%d)-v1awifi.zip"
fi
cp "$ZIP" "$FINAL"
( cd "$OUT_DIR" && sha256sum "$(basename "$FINAL")" > "$(basename "$FINAL").sha256" )

log "TAMAMLANDI"
echo "ROM:      $WORKDIR/$FINAL"
echo "SHA-256:  $(cat "$FINAL.sha256")"
