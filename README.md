Test--Linux User Creation Bash Script
Using Bash Scripts to Automate User Management in Linux

In environments with multiple users and complex access requirements, managing user accounts on a Linux system can be a time-consuming task. Scripting automation improves security, preserves uniformity across user configurations, and streamlines this procedure. This article will examine a Bash script that can be used to automate tasks related to user management on a Linux system, with a focus on the script's features, organization, and advantages.

Overview of the Script
The script (create_users.sh) is designed to automate several key aspects of user management:

Initialization and Setup
# Define the log and password file path
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Ensure necessary directories exist and set permissions
sudo mkdir -p /var/log /var/secure
sudo touch $LOG_FILE $PASSWORD_FILE
sudo chmod 600 $LOG_FILE $PASSWORD_FILE
Purpose: Initializes paths for logging user management activities (LOG_FILE) and storing generated passwords (PASSWORD_FILE).
Setup: Creates required directories (/var/log and /var/secure) if they do not exist and sets strict permissions to protect sensitive information.
Input File Validation
# Check if the input file is provided
if [ -z "$1" ]; then
    echo "Error: Please provide a text file containing user data as an argument."
    exit 1
fi
Purpose: Ensures the script is executed with an input file (user.txt) containing user data.
Error Handling: Exits gracefully if no input file is provided, preventing execution without necessary data.
User and Group Management
# Read the input file line by line
while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue

    # Extract username and groups
    IFS=';' read -r username groups <<< "$line"
    username=$(echo $username | xargs) # Trim whitespace
    groups=$(echo $groups | xargs)     # Trim whitespace

    # Create user's personal group if not exists
    if ! getent group "$username" > /dev/null; then
        sudo groupadd "$username"
        echo "$(date): Created group $username" >> $LOG_FILE
    fi

    # Create user if not exists
    if ! id -u "$username" > /dev/null 2>&1; then
        sudo useradd -m -g "$username" "$username"
        echo "$(date): Created user $username" >> $LOG_FILE
    fi

    # Add user to specified groups
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
done < "$1"
Purpose: Iterates through each line of the input file (user.txt), extracts usernames and group memberships, creates users and groups if they do not exist, and assigns users to specified groups.
Flexibility: Supports multiple group memberships per user, ensuring adaptable user management.
Password Management
# Generate random password
password=$(/usr/bin/openssl rand -base64 12)
echo "$username,$password" >> $PASSWORD_FILE

# Set user's password
echo "$username:$password" | sudo chpasswd
echo "$(date): Set password for $username" >> $LOG_FILE
Purpose: Generates a random password securely using OpenSSL, logs it along with the username in PASSWORD_FILE, and sets the password using chpasswd.
Security: Ensures passwords are randomly generated and securely stored, minimizing vulnerabilities.
Permissions and Logging
# Set permissions and ownership for home directory
sudo chown -R "$username:$username" "/home/$username"
sudo chmod 700 "/home/$username"
echo "$(date): Set permissions for /home/$username" >> $LOG_FILE
Purpose: Sets appropriate permissions (chmod) and ownership (chown) for each user’s home directory to maintain security and privacy.
Logging: Records all actions (user creation, group management, password setting) in $LOG_FILE, providing an audit trail for administrators.
Conclusion
Linux environments can benefit greatly from the efficiency, consistency, and security that come with automating user management tasks with scripts such as `create_users.sh}. Automating repetitive tasks allows system administrators to concentrate on more strategic aspects of system management and guarantee that security best practices are followed.

Platforms such as HNG Tech provide opportunities for people who are interested in learning more about automation and system administration to work on real-world projects and challenges, improving their skills in Linux administration and other areas.

Learn more about HNG Internship:

HNG Internship Overview
HNG Premium
System administrators can enhance workflows, increase operational effectiveness, and contribute to a more secure computing environment by utilizing automation tools effectively.

This article gives administrators the fundamental knowledge they need to comprehend and apply automated user management in Linux, enabling them to improve system security and expedite operations.
