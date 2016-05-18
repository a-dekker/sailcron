# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop on filename must be changed
#   -  filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-sailcron

DEPLOYMENT_PATH = /usr/share/$${TARGET}

translations.files = translations
translations.path = $${DEPLOYMENT_PATH}

CONFIG += sailfishapp

TEMPLATE = subdirs
SUBDIRS = src/sailcron-helper src

OTHER_FILES += qml/sailcron.qml \
    qml/cover/CoverPage.qml \
    rpm/sailcron.changes.in \
    rpm/sailcron.spec \
    translations/*.ts \
    harbour-sailcron.desktop \
    qml/pages/About.qml \
    qml/pages/MainPage.qml \
    qml/pages/SettingPage.qml \
    qml/pages/AddPage.qml \
    helper/sailcronhelper.sh \
    python/cron_descriptor/CasingTypeEnum.py \
    python/cron_descriptor/DescriptionTypeEnum.py \
    python/cron_descriptor/Exception.py \
    python/cron_descriptor/ExpressionDescriptor.py \
    python/cron_descriptor/ExpressionParser.py \
    python/cron_descriptor/GetText.py \
    python/cron_descriptor/__init__.py \
    python/cron_descriptor/__main__.py \
    python/cron_descriptor/Options.py \
    python/cron_descriptor/StringBuilder.py \
    python/cron_descriptor/Tools.py \
    python/cron_descriptor/locale/cs_CZ.mo \
    python/cron_descriptor/locale/cs_CZ.po \
    python/cron_descriptor/locale/de_DE.mo \
    python/cron_descriptor/locale/de_DE.po \
    python/cron_descriptor/locale/es_ES.mo \
    python/cron_descriptor/locale/es_ES.po \
    python/cron_descriptor/locale/fr_FR.mo \
    python/cron_descriptor/locale/fr_FR.po \
    python/cron_descriptor/locale/it_IT.mo \
    python/cron_descriptor/locale/it_IT.po \
    python/cron_descriptor/locale/nb_NO.mo \
    python/cron_descriptor/locale/nb_NO.po \
    python/cron_descriptor/locale/nl_NL.mo \
    python/cron_descriptor/locale/nl_NL.po \
    python/cron_descriptor/locale/pt_PT.mo \
    python/cron_descriptor/locale/pt_PT.po \
    python/cron_descriptor/locale/ru_RU.mo \
    python/cron_descriptor/locale/ru_RU.po \
    python/cron_descriptor/locale/tr_TR.mo \
    python/cron_descriptor/locale/tr_TR.po \
    python/cron_descriptor/locale/uk_UA.mo \
    python/cron_descriptor/locale/uk_UA.po \
    python/cron_descriptor/locale/zh_CN.mo \
    python/cron_descriptor/locale/zh_CN.po \
    rpm/sailcron.spec

INSTALLS += translations

TRANSLATIONS = translations/harbour-sailcron-nl.ts \
               translations/harbour-sailcron-sv.ts

# only include these files for translation:
lupdate_only {
    SOURCES = qml/*.qml \
              qml/pages/*.qml
}

script.files = helper/*
script.path = /usr/share/harbour-sailcron/helper

python.files = python/cron_descriptor/*
python.path = /usr/share/harbour-sailcron/python/cron_descriptor

icon86.files += icons/86x86/harbour-sailcron.png
icon86.path = /usr/share/icons/hicolor/86x86/apps

icon108.files += icons/108x108/harbour-sailcron.png
icon108.path = /usr/share/icons/hicolor/108x108/apps

icon128.files += icons/128x128/harbour-sailcron.png
icon128.path = /usr/share/icons/hicolor/128x128/apps

icon256.files += icons/256x256/harbour-sailcron.png
icon256.path = /usr/share/icons/hicolor/256x256/apps

INSTALLS += icon86 icon108 icon128 icon256 script python

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
