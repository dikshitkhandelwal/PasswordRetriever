import os
import time
import win32api
import win32security
import win32ts
from docx import Document

# Function to get the current logged in user's SID
def get_user_sid():
    return win32security.GetTokenInformation(win32security.OpenProcessToken(win32api.GetCurrentProcess(), win32security.TOKEN_READ), win32security.TokenUser)[0]

# Function to get the current window station and desktop
def get_window_station_and_desktop():
    station = win32ts.WTSGetActiveConsoleSessionId()
    user_sid = get_user_sid()
    winstation = win32ts.WTSQueryUserToken(station, user_sid, False)
    desktop = win32ts.WTSQueryUserToken(station, user_sid, True)
    return winstation, desktop

# Function to monitor for changes to the password
def monitor_password_change():
    # Get the current window station and desktop
    winstation, desktop = get_window_station_and_desktop()

    # Create a document object and open the Word document
    document = Document('My Passwords.docx')

    # Get the initial password hash for comparison
    password_hash = win32api.GetProfileType(7)['PasswordHash']

    while True:
        # Wait for 1 second before checking for password changes
        time.sleep(1)

        # Check if the current user has changed their password
        if password_hash != win32api.GetProfileType(7)['PasswordHash']:
            # The user has changed their password
            print('Password Changed')
            # Get the new password from the system
            new_password = win32api.GetProfileType(7)['Password']
            # Update the password in the Word document
            for table in document.tables:
                for row in table.rows:
                    if row.cells[0].text.lower() == 'my account name':
                        row.cells[1].text = new_password
            # Save the Word document
            document.save('My Passwords.docx')
            # Set the new password hash for comparison
            password_hash = win32api.GetProfileType(7)['PasswordHash']
