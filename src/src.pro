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

