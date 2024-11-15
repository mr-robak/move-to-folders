#!/bin/bash

# Get the current directory or use the specified directory as an argument
DIR=${1:-.}

# Exclude the script file itself
SCRIPT_NAME=$(basename "$0")

# Collect a list of files and simulate operations
declare -A SIMULATED_OUTPUT

# Scan the directory and identify files to process
echo "Scanning directory: $DIR"
for FILE in "$DIR"/*; do
    # Skip if the current item is the script file
    if [[ "$(basename "$FILE")" == "$SCRIPT_NAME" ]]; then
        continue
    fi

    # Check if the current item is a regular file
    if [ -f "$FILE" ]; then
        # Extract the base name of the file
        BASENAME=$(basename "$FILE")
        
        # Add the file to the simulated list
        SIMULATED_OUTPUT["$FILE"]="$BASENAME"
    fi
done

# Display the files found
if [[ ${#SIMULATED_OUTPUT[@]} -eq 0 ]]; then
    echo "No files found to process in the directory: $DIR"
    exit 0
fi

echo "The following files were found:"
for FILE in "${!SIMULATED_OUTPUT[@]}"; do
    echo "  - $FILE"
done

# Prompt the user for the number of characters to remove
read -p "Enter the number of characters to remove from the start of each file name (leave empty for none): " N

# Default to 0 if no input is provided
if [[ -z "$N" ]]; then
    N=0
fi

# Validate the input
if ! [[ "$N" =~ ^[0-9]+$ ]]; then
    echo "Invalid input. Please enter a valid number."
    exit 1
fi

# Simulate the new structure
echo "Simulated new structure:"
for FILE in "${!SIMULATED_OUTPUT[@]}"; do
    BASENAME="${SIMULATED_OUTPUT["$FILE"]}"
    NEWNAME="${BASENAME:N}"
    FOLDER_NAME="${NEWNAME%.*}"
    echo "  Folder: $DIR/$FOLDER_NAME"
    echo "    -> File: $DIR/$FOLDER_NAME/$NEWNAME"
done

# Ask the user whether to proceed
read -p "Do you want to proceed? [y/n]: " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Prompt the user to choose an action
echo "Choose an action:"
echo "  c - Copy files into folders"
echo "  m - Move files into folders"
echo "  r - Rename files in place (remove characters only)"
read -p "Enter your choice [c/m/r]: " ACTION

# Validate the user's choice
if [[ "$ACTION" != "c" && "$ACTION" != "m" && "$ACTION" != "r" ]]; then
    echo "Invalid choice. Please enter 'c', 'm', or 'r'."
    exit 1
fi

# Perform the selected operation
COUNT=0
for FILE in "${!SIMULATED_OUTPUT[@]}"; do
    BASENAME="${SIMULATED_OUTPUT["$FILE"]}"
    NEWNAME="${BASENAME:N}"
    FOLDER_NAME="${NEWNAME%.*}"
    
    if [[ "$ACTION" == "r" ]]; then
        # Rename the file in place
        mv "$FILE" "$DIR/$NEWNAME"
    else
        # Create the directory if it doesn't exist
        mkdir -p "$DIR/$FOLDER_NAME"
        
        if [[ "$ACTION" == "c" ]]; then
            # Copy the file into the new folder
            cp "$FILE" "$DIR/$FOLDER_NAME/$NEWNAME"
        elif [[ "$ACTION" == "m" ]]; then
            # Move the file into the new folder
            mv "$FILE" "$DIR/$FOLDER_NAME/$NEWNAME"
        fi
    fi

    # Increment the counter
    ((COUNT++))
done

# Display the summary
if [[ "$ACTION" == "r" ]]; then
    echo "Operation completed. Renamed $COUNT files in place."
else
    echo "Operation completed. Processed $COUNT files."
fi
