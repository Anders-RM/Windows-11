#add ssh key to github account using github api
import requests
import os

def add_ssh_key_to_github(username, token, title, key):
    url = f"https://api.github.com/user/keys"
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
        print("SSH key added successfully.")
    else:
        print("Failed to add SSH key.")
        print(f"Response: {response.text}")

# Provide your GitHub username, personal access token, SSH key title, and the actual SSH key content
# file deepcode ignore NoHardcodedCredentials: <The repository is private an is staying private>
username = "Anders-RM"
# file deepcode ignore HardcodedNonCryptoSecret: <The repository is private an is staying private>
token = "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"
title = "Home pc anders@Anders-Win"
key = os.path.expanduser('~\.ssh\id_rsa')

add_ssh_key_to_github(username, token, title, key)