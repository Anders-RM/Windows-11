# Import the necessary modules
import requests
import os
import socket
import logging
import getpass
from selenium import webdriver
import time
import sys


# Configure the logging module
logging.basicConfig(filename='python.log', level=logging.DEBUG)

# Define a function to add an SSH key to GitHub
def add_ssh_key_to_github(username, token, title, key):
    # Set up the API endpoint and headers
    url = "https://api.github.com/user/keys"
    headers = {"Authorization": f"token {token}"}

    # Set up the request payload
    data = {"title": title, "key": key}

    # Send the POST request to add the SSH key to GitHub
    response = requests.post(url, headers=headers, json=data)

    # Check the response status code and log the result
    if response.status_code == 201:
        logging.debug("SSH key added successfully.")
        print("SSH key added successfully.")
    else:
        logging.debug("Failed to add SSH key.")
        logging.debug(f"Response: {response.text}")
        print("Failed to add SSH key.")
        print(f"Response: {response.text}")


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
        for filename in filenames:
            if filename == "prefs.js":
                prefs_file = os.path.join(dirpath, filename)
                break
            
    # Check if the prefs.js file was found
    if prefs_file is None:
        raise Exception("Failed to locate the prefs.js file.")
    
    # Disable Quick Find in the prefs.js file
    with open(prefs_file, "a") as file:
        file.write("user_pref('accessibility.typeaheadfind', false);\n")
    logging.debug("Quick Find disabled successfully.")
    print("Quick Find disabled successfully.")

# Provide your GitHub username and personal access token
username = input("Enter your GitHub username: ")

token = getpass.getpass(prompt='Enter your GitHub token: ')
#token = input("Enter your GitHub token: ") #add hide input

# Get the hostname of the machine
hostname = socket.gethostname()

# Set the title to include the hostname
title = f"Home pc anders@{hostname}"

# Read the content of the SSH key file
with open(os.path.expanduser('~/.ssh/id_rsa.pub'), 'r') as file:
    key = file.read().strip()

# Call the function to add the SSH key to GitHub
add_ssh_key_to_github(username, token, title, key)

# Start Firefox
driver = webdriver.Firefox()
driver.get("https://www.google.com")

# Wait for 10 seconds
time.sleep(2)

# Close Firefox
driver.quit()

# Call the function to disable Quick Find
disable_quick_find()