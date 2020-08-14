#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QApplication>
#include <QtNetwork>
#include <QAccessibleTextUpdateEvent>
#include <QAccessibleTextSelectionEvent>
#include <QIcon>

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    QApplication::setOrganizationName("周卓");
    QApplication::setOrganizationDomain("zznote.top");

    app.setWindowIcon(QIcon(":/logo.png"));


    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}


