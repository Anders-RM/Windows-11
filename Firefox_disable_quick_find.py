# Import the necessary modules
import os
import logging
import sys
from shutil import which
from pathlib import Path

# Configure the logging module
logging.basicConfig(filename='python.log', level=logging.DEBUG)

# Define a function to check if Firefox is installed
def is_firefox_installed():
    return which("firefox") is not None

def disable_quick_find():
    # Map platforms to profile directory paths
    profile_paths = {
        'win': Path(os.getenv('APPDATA')) / 'Mozilla' / 'Firefox' / 'Profiles',
        'linux': Path.home() / '.mozilla' / 'firefox',
        'darwin': Path.home() / 'Library' / 'Application Support' / 'Firefox' / 'Profiles'
    }

    # Find the location of the Firefox profile directory
    platform = sys.platform[:3]
    if platform not in profile_paths:
        raise Exception("Unsupported operating system.")
    profile_dir = profile_paths[platform]

    # Locate the prefs.js file within the profile directory
    prefs_file = next(profile_dir.rglob('prefs.js'), None)

    # Check if the prefs.js file was found
    if prefs_file is None or not prefs_file.is_file():
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