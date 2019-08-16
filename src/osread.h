#ifndef SRC_OSREAD_H_
#define SRC_OSREAD_H_

#include <QObject>
#include <QProcess>

class Launcher : public QObject {
    Q_OBJECT
    Q_PROPERTY(
        QString message READ message WRITE setMessage NOTIFY
            outputReceived)  // this makes message available as a QML property
    Q_PROPERTY(
        int done READ done NOTIFY
            finishReceived)  // this makes done available as a QML property

   public:
    explicit Launcher(QObject *parent = 0);
    ~Launcher();
    Q_INVOKABLE QString launch(const QString &program);
    Q_INVOKABLE void launch_async(const QString &program);
    QString message() const;
    int done();
    void setMessage(const QString &value);
   public slots:
    void setMessageCall();
    void processFinished(int code, QProcess::ExitStatus status);

   private:
    QProcess *m_process;
    QProcess *m_process_async;
    QString m_message;
    int m_code;

   signals:
    void outputReceived();
    void finishReceived();
};

#endif  // SRC_OSREAD_H_
