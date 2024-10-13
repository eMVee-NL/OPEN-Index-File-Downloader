#!/bin/bash

# Define the ASCII art
ascii_art="
┏┓┏┓┏┓┳┓  ┳   ┓      ┏┓•┓    ┳┓       ┓     ┓      
┃┃┃┃┣ ┃┃  ┃┏┓┏┫┏┓┓┏  ┣ ┓┃┏┓  ┃┃┏┓┓┏┏┏┓┃┏┓┏┓┏┫┏┓┏┓  
┗┛┣┛┗┛┛┗  ┻┛┗┗┻┗ ┛┗  ┻ ┗┗┗   ┻┛┗┛┗┻┛┛┗┗┗┛┗┻┗┻┗ ┛  

Created by eMVee
"

# Print the ASCII art
echo "$ascii_art"

# Set the base URL and the output directory
# Set default URL
BASE_URL="http://localhost/data/"

# Function to print help message
print_help() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help      Display this help message"
  echo "  --url <url>     Specify the URL (default: $BASE_URL)"
  echo ""
  echo "Example: $0 --url https://example.com/data"
}

# Parse command-line arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help)
      print_help
      exit 0
      ;;
    --url)
      shift
      url="$1"
      ;;
    *)
      echo "Unknown option: $1"
      print_help
      exit 1
      ;;
  esac
  shift
done

# Print the URL
echo "Using URL: $BASE_URL"
OUTPUT_DIR=$(pwd)

# Create a temporary file to store the links
TMP_FILE=$(mktemp)

# Use wget to retrieve the HTML page and extract all links
wget -q -O - "$BASE_URL" | grep -oE 'href="[^"]+"' | sed 's/href="//' | sed 's/"//' > "$TMP_FILE"

# Initialize a counter for identified files
identified_files=0

# Initialize an array to store subdirectories with full base URL
subdirectories=()

echo "[%] Subdirectories:"
while IFS= read -r line; do
  # Check if the link is a subdirectory
  if [[ $line == */ ]]; then
    # Extract the subdirectory name and prepend the base URL
    SUBDIR_NAME="$BASE_URL${line%/}"
    echo "    [*] $SUBDIR_NAME"

    # Add the subdirectory to the subdirectories array
    subdirectories+=("$SUBDIR_NAME")
  fi
done < "$TMP_FILE"

# Download files from the base URL
echo "[%] Files identified"
while IFS= read -r line; do
  # Check if the link has an extension
  if [[ $line == *.* ]]; then
    # Extract the file name and directory from the link
    FILE_NAME=$(basename "$line")
    DIR_NAME=$(dirname "$line")

    # Create the directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR/$DIR_NAME"

    # Construct the full URL by prepending the base URL
    FULL_URL="$BASE_URL$line"

    # Download the file
    wget -q -O "$OUTPUT_DIR/$DIR_NAME/$FILE_NAME" "$FULL_URL"

    # Print the downloaded file
    echo "    [*] File: $DIR_NAME/$FILE_NAME"

    # Increment the identified files counter
    ((identified_files++))
  fi
done < "$TMP_FILE"

# Print the total number of identified files
echo "    [%] $identified_files Files identified"

# Create the subdirectories on the machine
for dir in "${subdirectories[@]}"; do
  # Create the subdirectory
  mkdir -p "$OUTPUT_DIR/${dir#$BASE_URL}"
done

# Create the subdirectories and download files recursively
for dir in "${subdirectories[@]}"; do
  # Fetch the contents of the subdirectory
  TMP_SUBDIR_FILE=$(mktemp)

  # Retrieve the HTML page of the subdirectory and extract links
  wget -q -O - "$dir" | grep -oE 'href="[^"]+"' | sed 's/href="//' | sed 's/"//' > "$TMP_SUBDIR_FILE"

  # Loop through each link in the subdirectory
  while IFS= read -r sub_line; do
    # Check if the link has an extension (indicating a file)
    if [[ $sub_line == *.* ]]; then
      # Extract the file name and directory from the link
      FILE_NAME=$(basename "$sub_line")
      DIR_NAME=$(dirname "$sub_line")

      # Remove the /./ from the DIR_NAME
      DIR_NAME=$(echo "$DIR_NAME" | sed 's/\/\.\///g')

      # Download the file
      REL_DIR=${dir#$BASE_URL}
      if [[ $sub_line =~ ^https?:// ]]; then
        wget -q -P "$OUTPUT_DIR/$REL_DIR/$DIR_NAME" "$sub_line"
      else
        wget -q -P "$OUTPUT_DIR/$REL_DIR/$DIR_NAME" "$BASE_URL$REL_DIR/$sub_line"
      fi
      echo "    [*] Downloaded file: $REL_DIR/$DIR_NAME/$FILE_NAME"
      ((identified_files++))
    fi
  done < "$TMP_SUBDIR_FILE"

  # Remove the temporary subdirectory file
  rm "$TMP_SUBDIR_FILE"
done

# Print the total number of
