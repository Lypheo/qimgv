#pragma once

#include <QStackedWidget>
#include "gui/folderview/folderviewproxy.h"
#include "gui/viewers/documentwidget.h"
#include "settings.h"
#include <QSplitter>


class CentralWidget : public QSplitter
{
    Q_OBJECT
public:
    explicit CentralWidget(std::shared_ptr<DocumentWidget> _docWidget, std::shared_ptr<FolderViewProxy> _folderView, QWidget *parent = nullptr);

    ViewMode currentViewMode();
signals:

public slots:
    void setMode(ViewMode new_mode);
private:
    std::shared_ptr<DocumentWidget> documentView;
    std::shared_ptr<FolderViewProxy> folderView;

    QByteArray splitterState;
    ViewMode mode;
};
