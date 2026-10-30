#
# Note Pro 12.2 Minimal ROM - sadelestirme katmani
#
# Bu dosya derleme betigi (scripts/build.sh) MINIMAL=1 ile calistirildiginda
# device/samsung/v1awifi/device.mk sonuna eklenen tek satirla devreye girer.
# LineageOS ve cihaz agacinin kendisine baska hicbir degisiklik yapilmaz.
#

# Gereksiz uygulamalari derlemeden cikar (bkz. packages/MinimalRemovePackages)
PRODUCT_PACKAGES += \
    MinimalRemovePackages

# Google sunucusu bagimliliklarini azaltan ve animasyonlari kisan ayarlar
PRODUCT_PACKAGE_OVERLAYS += vendor/minimal/overlay

# ROM surum etiketi (Ayarlar > Tablet hakkinda ekraninda dogrulama icin)
PRODUCT_PRODUCT_PROPERTIES += \
    ro.minimal.rom.version=0.1
