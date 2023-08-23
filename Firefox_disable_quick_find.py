# Import the necessary modules
import os
import logging
import sys
import subprocess


# Configure the logging module
logging.basicConfig(filename='python.log', level=logging.DEBUG)

# Define a function to check if Firefox is installed
def is_firefox_installed():
    try:
        subprocess.run(["firefox", "--version"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return True
    except FileNotFoundError:
        return False

def disable_quick_find():
    # Find the location of the Firefox profile directory
    if sys.platform.startswith('win'):
        app_data = os.getenv('APPDATA')
        profile_dir = os.path.join(app_data, 'Mozilla', 'Firefox', 'Profiles')
    elif sys.platform.startswith('linux'):
        home_dir = os.path.expanduser("~")
        profile_dir = os.path.join(home_dir, ".mozilla", "firefox")
    elif sys.platform.startswith('darwin'):
        home_dir = os.path.expanduser("~")
        profile_dir = os.path.join(home_dir, "Library", "Application Support", "Firefox", "Profiles")
    else:
        raise Exception("Unsupported operating system.")
    
    # Locate the prefs.js file within the profile directory
    prefs_file = None
    for dirpath, dirnames, filenames in os.walk(profile_dir):
        if "prefs.js" in filenames:
            prefs_file = os.path.join(dirpath, "prefs.js")
            break
            
    # Check if the prefs.js file was found
    if prefs_file is None or not os.path.isfile(prefs_file):
        raise Exception("Failed to locate the prefs.js file.")
    
    # Disable Quick Find in the prefs.js file
    with open(prefs_file, "a") as file:
        file.write("user_pref('accessibility.typeaheadfind', false);\n")
    logging.debug("Quick Find disabled successfully.")
    print("Quick Find disabled successfully.")

# Check if Firefox is installed before disabling Quick Find
if is_firefox_installed():
    # Call the function to disable Quick Find
    disable_quick_find()
else:
    print("Firefox is not installed, so Quick Find cannot be disabled.")