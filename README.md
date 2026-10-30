# Note Pro 12.2 Minimal ROM

Samsung Galaxy Note Pro 12.2 (**SM-P900 / v1awifi**) için Google'sız, sadeleştirilmiş, LineageOS 18.1 (Android 11) tabanlı ROM.

> **Durum:** Aşama 2 — derleme altyapısı hazırlanıyor. Henüz test edilmiş bir derleme yok.
> Yalnızca **SM-P900** içindir. SM-P901 / SM-P905 cihazlara yüklemeyin.

## Klasör yapısı

```
manifests/v1awifi.xml           Cihaz kaynaklarının listesi (repo local manifest)
scripts/crave-build.sh          crave.io'da derleme (crave kurallarına uygun)
scripts/local-build.sh          Kendi Linux bilgisayarında derleme
scripts/apply-minimal.sh        Sadeleştirme katmanını açar/kapatır
scripts/post-build.sh           ROM'u adlandırır, SHA-256 dosyası üretir
config/minimal.mk               Sadeleştirme katmanının giriş noktası
packages/MinimalRemovePackages  ROM'dan çıkarılan uygulamaların listesi
overlay/                        Google'sız ve hafif varsayılan ayarlar
```

Derleme sırasında bu depo kaynak ağacına `vendor/minimal` olarak eklenir.
`local_manifests` dalı yalnızca manifest dosyasını içerir; crave bunu `.repo/local_manifests` olarak klonlar.

## Derleme — crave.io (önerilen, ücretsiz)

Crave Devspace içinde, `crave clone create` ile açılmış proje klasöründe:

```bash
curl -fsSLO https://raw.githubusercontent.com/erdinc1911/notepro-minimal-rom/main/scripts/crave-build.sh
bash crave-build.sh              # Aşama 2: değiştirilmemiş LineageOS 18.1
MINIMAL=1 bash crave-build.sh    # Aşama 4: sadeleştirilmiş ROM
bash crave-build.sh pull         # bitmiş ROM'u indir
```

Kurallar gereği kaynak indirme ve derleme yalnızca `crave run` içinde yapılır, `--clean` kullanılmaz,
indirilen dosyalar sonra devspace'ten silinir ([kurallar](https://fosson.top/crave/rules.html)).

**Açık soru:** crave'de Android 11 tabanlı bir proje olup olmadığı. Onaydan sonra `crave clone list` ile bakılacak.

## Derleme — kendi bilgisayarında

Linux x86-64, en az 16 GB (önerilen 32 GB) RAM ve ~300 GB boş disk gerekir.

```bash
curl -fsSL https://raw.githubusercontent.com/erdinc1911/notepro-minimal-rom/main/scripts/local-build.sh | MINIMAL=0 bash
```

Çıktı: `out/target/product/v1awifi/notepro-*.zip` ve yanında `.sha256` doğrulama dosyası.

## Kurulum (özet)

1. TWRP'de EFS + Boot yedeği alınmış ve bilgisayara kopyalanmış olmalı.
2. Bilgisayarda: `sha256sum` / `certutil -hashfile <dosya> SHA256` ile özeti karşılaştırın.
3. TWRP → Temizle → Format Data, ardından Gelişmiş Temizleme → System, Cache, Dalvik.
4. TWRP → Gelişmiş → ADB Sideload, bilgisayarda: `adb sideload notepro-....zip`

## Sadeleştirme katmanının yaptıkları

| Değişiklik | Dosya |
| --- | --- |
| Jelly, Etar, E-posta, Kayıt, Seedvault, Güncelleyici, Kamera uygulaması, Kişiler vb. çıkarılır | `packages/MinimalRemovePackages/Android.mk` |
| Saat eşitleme `pool.ntp.org` üzerinden | `overlay/.../core/res/res/values/config.xml` |
| Animasyonlar yarı sürede, ekran zaman aşımı 5 dk | `overlay/.../SettingsProvider/res/values/defaults.xml` |

Planlanan (henüz yok): Cromite tarayıcı + WebView, PDF görüntüleyici, bağlantı kontrolünün Google dışı sunucuya taşınması, zRAM ayarı.

## Test durumu

| Özellik | Durum |
| --- | --- |
| Açılış | Test edilmedi |
| Wi-Fi | Test edilmedi |
| Dokunmatik | Test edilmedi |
| S Pen + basınç | Test edilmedi |
| Bluetooth ses | Test edilmedi |
| Hoparlör / kulaklık / mikrofon | Test edilmedi |
| USB / MTP | Test edilmedi |
| Miracast (kablosuz alıcı) | Test edilmedi — Samsung yazılımıyla aynı alıcıda çalıştığı doğrulandı |

## Kaynaklar

Cihaz ağacı, kernel ve Samsung dosyaları: [exynos5420](https://github.com/exynos5420) topluluğu. Taban: [LineageOS](https://github.com/LineageOS).
