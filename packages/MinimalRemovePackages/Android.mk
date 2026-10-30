#
# MinimalRemovePackages
#
# Bos bir "gecersiz kilma" (override) paketi. Asagidaki listede yer alan
# uygulamalar ROM'a kopyalanmaz. Uygulamalarin kaynak kodu silinmez; listeden
# bir satiri kaldirmak o uygulamayi geri getirir.
#
# Korunanlar (bilincli olarak listede YOK): Settings, SystemUI, Trebuchet
# (ana ekran), LatinIME (klavye), Eleven (muzik), DeskClock, ExactCalculator,
# DocumentsUI (dosyalar), Gallery2, AudioFX, LineageParts, LineageSetupWizard,
# ve tum saglayicilar (ContactsProvider, CalendarProvider, MediaProvider vb.).
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := MinimalRemovePackages
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_TAGS := optional
LOCAL_OVERRIDES_PACKAGES := \
    Jelly \
    Etar \
    Email \
    Exchange2 \
    Recorder \
    Seedvault \
    Updater \
    Profiles \
    Backgrounds \
    QuickAccessWallet \
    Camera2 \
    Contacts \
    Dialer \
    Messaging \
    Music \
    QuickSearchBox \
    LiveWallpapersPicker
LOCAL_UNINSTALLABLE_MODULE := true
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_SRC_FILES := /dev/null
include $(BUILD_PREBUILT)
