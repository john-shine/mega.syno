#!/usr/bin/python3
import sys
import resources
import traceback
import subprocess
from PyQt5 import QtGui
from PyQt5.QtCore import Qt, QRect
from PyQt5.QtWidgets import QMainWindow, QApplication, QPushButton, QDesktopWidget


class Tray(QMainWindow):
    
    def __init__(self):
        super().__init__()
        self.icon_size = 32
        self.initUI()
        
    def initUI(self): 
        width = QDesktopWidget().screenGeometry(-1).width()

        self.setWindowTitle('system tray')
        self.setWindowFlags(Qt.CustomizeWindowHint)
        self.setWindowFlags(Qt.FramelessWindowHint)
        self.setWindowFlag(Qt.WindowCloseButtonHint, False)
        self.setWindowFlag(Qt.WindowMinimizeButtonHint, False)     
        
        self.button = QPushButton('', self)
        self.button.setGeometry(QRect(width - self.icon_size - 1, 0, self.icon_size, self.icon_size))
        ico = QtGui.QPixmap(':/mega.ico')
        self.button.setIcon(QtGui.QIcon(ico))
        self.button.clicked.connect(self.launch_mega)
        
        self.setGeometry(0, 0, width, self.icon_size)
        self.setFixedSize(self.width(), self.height())

        self.show()

    def launch_mega(self):
        try:
            subprocess.Popen(['/usr/bin/megasync', '&'])
        except Exception as e:
            traceback.print_exc()


if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = Tray()
    sys.exit(app.exec_())
