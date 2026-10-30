#!/usr/bin/env bash
#
# crave.io uzerinde derleme (crave kurallarina uygun).
#
# Bu betik crave Devspace CLI icinde, `crave clone create` ile olusturulmus
# proje klasorunden calistirilir. Kaynak kodu indirme ve derleme islemleri
# kuralin istedigi gibi YALNIZCA `crave run` icinde yapilir; devspace'te
# repo sync / make / mka calistirilmaz.
#
# Kullanim (devspace icinde, proje klasorunde):
#   bash crave-build.sh            # Asama 2: degistirilmemis LineageOS 18.1
#   MINIMAL=1 bash crave-build.sh  # Asama 4: sadelestirilmis ROM
#   bash crave-build.sh pull       # bitmis ROM'u devspace'e indir
#
# Kurallar (fosson.top/crave/rules.html) geregi:
#   - --clean bayragi KULLANILMAZ (tam yeniden derleme moderator izni ister)
#   - ayni anda tek derleme
#   - indirilen .zip/.img dosyalari sonra devspace'ten silinir
#
set -euo pipefail

MINIMAL="${MINIMAL:-0}"
BUILD_TYPE="${BUILD_TYPE:-userdebug}"
REPO_URL="https://github.com/erdinc1911/notepro-minimal-rom"

command -v crave >/dev/null || { echo "HATA: crave istemcisi bulunamadi. Bu betik crave Devspace icinde calisir." >&2; exit 1; }

if [ "${1:-}" = "pull" ]; then
    crave pull 'out/target/product/v1awifi/notepro-*.zip'
    crave pull 'out/target/product/v1awifi/notepro-*.zip.sha256'
    echo "==> Indirildi. GitHub'a yukledikten sonra .zip dosyalarini devspace'ten silin."
    exit 0
fi

CMD="rm -rf .repo/local_manifests; \
repo init -u https://github.com/LineageOS/android.git -b lineage-18.1 --depth=1; \
git clone --depth 1 -b local_manifests ${REPO_URL} .repo/local_manifests; \
/opt/crave/resync.sh; \
MINIMAL=${MINIMAL} bash vendor/minimal/scripts/apply-minimal.sh; \
source build/envsetup.sh; \
lunch lineage_v1awifi-${BUILD_TYPE}; \
m bacon; \
MINIMAL=${MINIMAL} bash vendor/minimal/scripts/post-build.sh"

echo "==> crave run baslatiliyor (MINIMAL=${MINIMAL}, ${BUILD_TYPE})"
crave run --no-patch -- "$CMD"
