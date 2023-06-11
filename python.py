import requests
import os
import socket
import logging

# Configure the logging module
logging.basicConfig(filename='python.log', level=logging.DEBUG)



def add_ssh_key_to_github(username, token, title, key):
    """
    Adds an SSH key to a GitHub account using the GitHub API.

    Args:
        username (str): The GitHub username.
        token (str): The personal access token for the GitHub account.
        title (str): The title of the SSH key.
        key (str): The content of the SSH key.

    Returns:
        None
    """
    url = "https://api.github.com/user/keys"
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github.v3+json"
    }
    data = {
        "title": title,
        "key": key
    }

    response = requests.post(url, headers=headers, json=data)
    if response.status_code == 201:
        logging.debug("SSH key added successfully.")
        print("SSH key added successfully.")
    else:
        logging.debug("Failed to add SSH key.")
        logging.debug(f"Response: {response.text}")
        print("Failed to add SSH key.")
        print(f"Response: {response.text}")

def disable_quick_find():
    """
    Disables Quick Find in Firefox by modifying the prefs.js file.

    Args:
        None

    Returns:
        None
    """
    # Find the location of the Firefox profile directory
    home_dir = os.path.expanduser("~")
    profile_dir = os.path.join(home_dir, ".mozilla", "firefox")
    
    # Locate the prefs.js file within the profile directory
    for dirpath, dirnames, filenames in os.walk(profile_dir):
        for filename in filenames:
            if filename == "prefs.js":
                prefs_file = os.path.join(dirpath, filename)
                break
    
    # Disable Quick Find in the prefs.js file
    if prefs_file:
        with open(prefs_file, "a") as file:
            file.write("user_pref('accessibility.typeaheadfind', false);\n")
        logging.debug("Quick Find disabled successfully.")
        print("Quick Find disabled successfully.")
    else:
        logging.debug("Failed to locate the prefs.js file.")
        print("Failed to locate the prefs.js file.")

# Provide your GitHub username and personal access token
username = ""
token = ""

# Get the hostname of the machine
hostname = socket.gethostname()

# Set the title to include the hostname
title = f"Home pc anders@{hostname}"

# Read the content of the SSH key file
with open(os.path.expanduser('~\.ssh\id_rsa.pub'), 'r') as file:
    key = file.read().strip()

# Call the function to add the SSH key to GitHub
add_ssh_key_to_github(username, token, title, key)

# Call the function to disable Quick Find
disable_quick_find()