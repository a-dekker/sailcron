PROJECT = harbour-sailcron
TARGET = sailcronhelper
QT -= gui
#CONFIG += sailfishapp

target.path = /usr/share/$$PROJECT/helper

SOURCES += \
    sailcron-helper.c

INSTALLS += target
