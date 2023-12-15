from typing import Optional
# Import the necessary modules
import os
import logging
import sys
import subprocess


# Configure the logging module76
logging.basicConfig(filename='python.log', level=logging.DEBUG)

# Define a function to check if Firefox is installed
def is_firefox_installed() -> bool:
    """
    Checks if Firefox is installed on the system.

    Returns:
        bool: True if Firefox is installed, False otherwise.
    """
    try:
        subprocess.run(["firefox", "--version"], capture_output=True, check=True)
        return True
    except subprocess.CalledProcessError:
        return False

def disable_quick_find():
    """
    Disables the Quick Find feature in Firefox by modifying the prefs.js file in the Firefox profile directory.

    Raises:
    Exception: If the operating system is not supported or if the prefs.js file cannot be located.
    """
    # Find the location of the Firefox profile directory
    profile_dir = get_firefox_profile_dir()
    
    # Locate the prefs.js file within the profile directory
    prefs_file = find_prefs_file(profile_dir)
    
    # Disable Quick Find in the prefs.js file
    disable_quick_find_in_prefs(prefs_file)
    
    logging.debug("Quick Find disabled successfully.")
    print("Quick Find disabled successfully.")

def get_firefox_profile_dir() -> str:
    """
    Returns the path to the Firefox profile directory based on the operating system.

    Returns:
    str: The path to the Firefox profile directory.

    Raises:
    Exception: If the operating system is not supported.
    """
    if sys.platform.startswith('win'):
        app_data = os.getenv('APPDATA')
        return os.path.join(app_data, 'Mozilla', 'Firefox', 'Profiles')
    elif sys.platform.startswith('linux'):
        home_dir = os.path.expanduser("~")
        return os.path.join(home_dir, ".mozilla", "firefox")
    elif sys.platform.startswith('darwin'):
        home_dir = os.path.expanduser("~")
        return os.path.join(home_dir, "Library", "Application Support", "Firefox", "Profiles")
    else:
        raise Exception("Unsupported operating system.")

def find_prefs_file(profile_dir: str) -> str:
    """
    Finds the prefs.js file within the Firefox profile directory.

    Args:
    profile_dir (str): The path to the Firefox profile directory.

    Returns:
    str: The path to the prefs.js file.

    Raises:
    Exception: If the prefs.js file cannot be located.
    """
    for dirpath, dirnames, filenames in os.walk(profile_dir):
        if "prefs.js" in filenames:
            return os.path.join(dirpath, "prefs.js")
    
    raise Exception("Failed to locate the prefs.js file.")

def disable_quick_find_in_prefs(prefs_file: str):
    """
    Disables the Quick Find feature in the prefs.js file.

    Args:
    prefs_file (str): The path to the prefs.js file.
    """
    with open(prefs_file, "a") as file:
        file.write("user_pref('accessibility.typeaheadfind', false);\n")

# Check if Firefox is installed before disabling Quick Find
if is_firefox_installed():
    # Call the function to disable Quick Find
    disable_quick_find()
else:
    print("Firefox is not installed, so Quick Find cannot be disabled.")