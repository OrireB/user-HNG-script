#!/bin/bash

# Define the log and password file path
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Ensure the necessary directories exist and set permissions
sudo mkdir -p /var/log /var/secure
sudo touch $LOG_FILE $PASSWORD_FILE
sudo chmod 600 $LOG_FILE $PASSWORD_FILE

# Check if the input file is provided
if [ -z "$1" ]; then
    echo "Error: Please provide a text file containing user data as an argument."
    exit 1
fi

# Read the input file line by line
while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue

    # Extract username and groups
    IFS=';' read -r username groups <<< "$line"
    username=$(echo $username | xargs) # Trim whitespace
    groups=$(echo $groups | xargs)     # Trim whitespace

    # Create the user's personal group if it doesn't exist
    if ! getent group "$username" > /dev/null; then
        sudo groupadd "$username"
        echo "$(date): Created group $username" >> $LOG_FILE
    fi

    # Create the user if it doesn't exist
    if ! id -u "$username" > /dev/null 2>&1; then
        sudo useradd -m -g "$username" "$username"
        echo "$(date): Created user $username" >> $LOG_FILE
    fi

    # Add the user to the specified groups
    IFS=',' read -ra group_array <<< "$groups"
    for group in "${group_array[@]}"; do
        group=$(echo $group | xargs) # Trim whitespace
        if ! getent group "$group" > /dev/null; then
            sudo groupadd "$group"
            echo "$(date): Created group $group" >> $LOG_FILE
        fi
        sudo usermod -aG "$group" "$username"
        echo "$(date): Added $username to group $group" >> $LOG_FILE
    done

    # Generate a random password
    password=$(/usr/bin/openssl rand -base64 12)
    echo "$username,$password" >> $PASSWORD_FILE

    # Set the user's password
    echo "$username:$password" | sudo chpasswd
    echo "$(date): Set password for $username" >> $LOG_FILE

    # Set permissions and ownership for the home directory
    sudo chown -R "$username:$username" "/home/$username"
    sudo chmod 700 "/home/$username"
    echo "$(date): Set permissions for /home/$username" >> $LOG_FILE

done < "$1"

echo "User, group, and password creation complete. Details logged to $LOG_FILE."
