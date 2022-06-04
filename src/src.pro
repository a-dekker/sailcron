TEMPLATE = app

TARGET = harbour-sailcron
CONFIG += sailfishapp

#QT += declarative

SOURCES += sailcron.cpp \
    settings.cpp \
    osread.cpp

HEADERS += \
    settings.h \
    osread.h

CONFIG(release, debug|release) {
    DEFINES += QT_NO_DEBUG_OUTPUT
}

OTHER_FILES +=

isEmpty(VERSION) {
    VERSION = $$system( egrep "^Version:\|^Release:" ../rpm/sailcron.spec |tr -d "[A-Z][a-z]: " | tr "\\\n" "-" | sed "s/\.$//g"| tr -d "[:space:]")
    message("VERSION is unset, assuming $$VERSION")
}
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
DEFINES += BUILD_YEAR=$$system(date '+%Y')
