import sys
import mysql.connector
import datetime
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QComboBox, QTableView, QVBoxLayout, QWidget, 
    QPushButton, QDialog, QLineEdit, QLabel, QDialogButtonBox, QMessageBox, QGridLayout 
)
from PyQt5.QtCore import QAbstractTableModel, Qt

# Custom Table Model
class CustomTableModel(QAbstractTableModel):
    def __init__(self, data):
        super(CustomTableModel, self).__init__()
        self._data = data
        self.headers = []

    def rowCount(self, parent=None):
        return len(self._data)

    def columnCount(self, parent=None):
        return len(self.headers) if self._data else 0

    def data(self, index, role=Qt.DisplayRole):
        if role == Qt.DisplayRole:
            value = self._data[index.row()][index.column()]
            # Check if the value is a date instance and format it
            if isinstance(value, (datetime.date, datetime.datetime)):
                return value.strftime("%Y-%m-%d")  # Format date as needed
            return value
        return None


    def headerData(self, section, orientation, role):
        if role == Qt.DisplayRole and orientation == Qt.Horizontal:
            if section < len(self.headers):
                return self.headers[section]
        return None

class DynamicForm(QDialog):
    def __init__(self, table_structure, parent=None):
        super(DynamicForm, self).__init__(parent)
        self.setWindowTitle('Erecruit Data')

        self.setStyleSheet("""
            QDialog {
                background-color: #1e293b;
            }
            QLabel {
                font-size: 14px;
                color: #cbd5e1;
                font-weight: bold;
            }
            QLineEdit {
                border: 1px solid #ccc;
                background-color: #17202e;
                padding: 5px;
                font-size: 14px;
                color: #ea580c;
                font-weight: bold;
            }
            QPushButton {
                background-color: #ea580c;
                color: #cbd5e1;
                font-weight: bold;
                padding: 6px;
                border-radius: 4px;
                font-size: 14px;
            }
            QPushButton:hover {
                background-color: #c44d27;
            }
        """)

        layout = QVBoxLayout(self)

        self.inputs = {}
        for column, col_type, *_ in table_structure:
            self.inputs[column] = QLineEdit(self)
            layout.addWidget(QLabel(column))
            layout.addWidget(self.inputs[column])



        self.buttons = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel, self)
        self.buttons.accepted.connect(self.accept)
        self.buttons.rejected.connect(self.reject)
        layout.addWidget(self.buttons)

    def getInputs(self):
        return {column: self.inputs[column].text() for column in self.inputs}


class DatabaseApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.conn = self.createDatabaseConnection()
        self.initUI()

    def createDatabaseConnection(self):
        config = {
            "host": "localhost",
            "port": 3306,
            "user": "root",
            "password": "",
            "database": "PDB2024"
        }
        try:
            conn = mysql.connector.connect(**config)
            print("Successfully connected to the database!")
            return conn
        except mysql.connector.Error as e:
            self.showErrorDialog(f"Error connecting to MySQL: {e}")
            sys.exit(1)

    def showErrorDialog(self, message):
        msgBox = QMessageBox()
        msgBox.setIcon(QMessageBox.Critical)
        msgBox.setText("An error occurred")
        msgBox.setInformativeText(message)
        msgBox.setWindowTitle("Error")
        # Custom styling
        msgBox.setStyleSheet("""
        QMessageBox {
            background-color: #2C3E50;
            color: orange;
            font-weight: bold;
        }
        QMessageBox QPushButton {
            background-color: #18BC9C;
            color: #EAECEE;
            border-radius: 5px;
            padding: 6px;
            margin: 4px;
        }
        QMessageBox QPushButton:hover {
            background-color: #1ABC9C;
        }
        QMessageBox QPushButton:pressed {
            background-color: #16A085;
        }
        """)
        
        msgBox.exec_()


    def initUI(self):
        self.setWindowTitle('Database Management App')
        self.setGeometry(100, 100, 1000, 800)
        self.setFixedSize(1200, 400)
        self.setStyleSheet("QMainWindow { background-color: #475569; }")

        # Main layout
        gridLayout = QGridLayout()

        # Dropdown for table selection
        self.tableDropdown = QComboBox(self)
        self.tableDropdown.setStyleSheet("QComboBox { background-color: #0f172a; color:#ea580c; font-weight:bold; }")
        self.tableDropdown.addItems(["Select a table","User", "Etaireia", "Evaluator", "Employee", "Languages", "Project", "Job", "Applies", "Subject", "Requires", "Degree", "Has_degree","application_history"])
        self.tableDropdown.currentIndexChanged.connect(self.tableSelected)
        gridLayout.addWidget(self.tableDropdown, 0, 0)

        # Table view to display data
        self.tableView = QTableView(self)
        self.tableView.setStyleSheet("""
            QTableView {
                border: 1px solid #d4d4d4;
                selection-background-color: #a2d2ff;
                gridline-color: #d4d4d4; 
                font-size: 12px;
                font-family: 'Helvetica';
                font-weight: bold;
            }
            QTableView::item {
                padding: 5px;
            }
            QHeaderView::section {
                background-color: #1e293b;
                padding: 4px;
                border: 1px solid #d4d4d4;
                font-size: 14px;
                font-weight: bold;
                color: #ea580c;
            }
            QTableView::item:selected {
                background-color: #ea580c;
                color: #0f172a;
            }
        """)
        gridLayout.addWidget(self.tableView, 1, 0,)

        # Button styles
        button_style = """
        QPushButton {
            background-color: #1e293b;
            color: #ea580c;
            border-style: outset;
            border-width: 2px;
            border-radius: 10px;
            border-color: beige;
            font: bold 14px;
            min-width: 10em;
            padding: 6px;
        }
        QPushButton:hover {
            background-color: #0f172a;
        }
        QPushButton:pressed {
            background-color: #1e293b;
            border-style: inset;
        }
        """


        buttonLayout = QVBoxLayout()
        # Create CRUD operation buttons
        self.addButton = QPushButton('Add', self)
        self.addButton.setStyleSheet(button_style)
        self.addButton.clicked.connect(self.addRecord)
        buttonLayout.addWidget(self.addButton)
        
        self.editButton = QPushButton('Edit', self)
        self.editButton.setStyleSheet(button_style)
        self.editButton.clicked.connect(self.editRecord)
        buttonLayout.addWidget(self.editButton)
        
        self.deleteButton = QPushButton('Delete', self)
        self.deleteButton.setStyleSheet(button_style)
        self.deleteButton.clicked.connect(self.deleteRecord)
        buttonLayout.addWidget(self.deleteButton)

        # Button layout
        buttonLayout = QVBoxLayout()
        buttonLayout.addWidget(self.addButton)
        buttonLayout.addWidget(self.editButton)
        buttonLayout.addWidget(self.deleteButton)
        gridLayout.addLayout(buttonLayout, 1, 1)

        gridLayout.setColumnStretch(0, 3)  
        gridLayout.setColumnStretch(1, 1)

        # Set the layout to the QWidget
        centralWidget = QWidget()
        centralWidget.setLayout(gridLayout)
        self.setCentralWidget(centralWidget)

        # Display the main window
        self.show()


    def getTableStructure(self, table_name):
        cursor = self.conn.cursor()
        cursor.execute(f"DESCRIBE {table_name}")
        return cursor.fetchall()  # Returns a list of columns and their types

    def getSelectedRowData(self):
        selected_index = self.tableView.currentIndex()
        if not selected_index.isValid():
            return None
        return selected_index.row()

    def addRecord(self):
        selected_table = self.tableDropdown.currentText()
        table_structure = self.getTableStructure(selected_table)

        dialog = DynamicForm(table_structure, self)
        if dialog.exec_() == QDialog.Accepted:
            inputs = dialog.getInputs()
            # Insert data into the database
            self.insertData(selected_table, inputs)
            self.refreshTable()

    def updateData(self, table_name, new_data, old_data):
        # Construct the UPDATE statement
        set_clause = ', '.join([f"{key} = %s" for key in new_data.keys()])
        primary_key_column = self.getTableStructure(table_name)[0][0]
        primary_key_value = old_data[0]

        query = f"UPDATE {table_name} SET {set_clause} WHERE {primary_key_column} = %s"
        values = list(new_data.values()) + [primary_key_value]

        try:
            cursor = self.conn.cursor()
            cursor.execute(query, values)
            self.conn.commit()
        except mysql.connector.Error as e:
            self.showErrorDialog(f"Error updating data in {table_name}: {e}")

    
    def editRecord(self):
        row = self.getSelectedRowData()
        if row is None:
            return  # No row selected

        selected_table = self.tableDropdown.currentText()
        table_structure = self.getTableStructure(selected_table)
        print("Table Structure:", table_structure)
        current_data = self.model._data[row]

        dialog = DynamicForm(table_structure, self)
        for i, column in enumerate(table_structure):
            dialog.inputs[column[0]].setText(str(current_data[i]))

        if dialog.exec_() == QDialog.Accepted:
            inputs = dialog.getInputs()
            self.updateData(selected_table, inputs, current_data)
            self.refreshTable()

    def insertData(self, table_name, data):
        # Prepare and execute INSERT statement
        columns = ', '.join(data.keys())
        placeholders = ', '.join(['%s'] * len(data))
        values = tuple(data.values())

        query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"
        try:
            cursor = self.conn.cursor()
            cursor.execute(query, values)
            self.conn.commit()
        except mysql.connector.Error as e:
             self.showErrorDialog(f"Error inserting data into {table_name}: {e}")
    
    def deleteData(self, table_name, pk_column, pk_value):
        # Prepare the DELETE statement
        query = f"DELETE FROM {table_name} WHERE {pk_column} = %s"

        try:
            cursor = self.conn.cursor()
            cursor.execute(query, (pk_value,))
            self.conn.commit()
        except mysql.connector.Error as e:
            self.showErrorDialog(f"Error deleting data from {table_name}: {e}")



    def deleteRecord(self):
        row = self.getSelectedRowData()
        if row is None:
            return  # No row selected

        selected_table = self.tableDropdown.currentText()
        primary_key_column = self.getTableStructure(selected_table)[0][0]
        primary_key_value = self.model._data[row][0]

        reply = QMessageBox.question(self, 'Confirm Deletion', 
                                     "Are you sure you want to delete this record?",
                                     QMessageBox.Yes | QMessageBox.No, QMessageBox.No)

        if reply == QMessageBox.Yes:
            self.deleteData(selected_table, primary_key_column, primary_key_value)
            self.refreshTable()


    def refreshTable(self):
        selected_table = self.tableDropdown.currentText()
        data, headers = self.fetchDataFromDatabase(selected_table)
        self.model = CustomTableModel(data)
        self.model.headers = headers
        self.tableView.setModel(self.model)
        self.tableView.resizeColumnsToContents()


    def tableSelected(self, index):
        table_name= self.tableDropdown.itemText(index)
        # Fetch data from the database for the selected table
        data, headers = self.fetchDataFromDatabase(table_name)
        # Set the headers and data for the CustomTableModel
        self.model = CustomTableModel(data)
        self.model.headers = headers
        self.tableView.setModel(self.model)
        # Update the table view to adjust columns to content
        self.tableView.resizeColumnsToContents()


    def fetchDataFromDatabase(self, table_name):
    # Implement logic to fetch data from the database
        try:
            cursor = self.conn.cursor()
            cursor.execute(f"DESCRIBE {table_name}")
            # Fetch column headers
            headers = [column[0] for column in cursor.fetchall()]
            
            cursor.execute(f"SELECT * FROM {table_name}")
            # Fetch all results as a list of tuples
            rows = cursor.fetchall()
            return rows, headers  # Return rows and headers
        except mysql.connector.Error as e:
            self.showErrorDialog(f"Error fetching data from {table_name}: {e}")
            return [], []  # Return empty lists on error


if __name__ == "__main__":
    app = QApplication(sys.argv)
    ex = DatabaseApp()
    font_family = "Helvetica"
    sys.exit(app.exec_())


