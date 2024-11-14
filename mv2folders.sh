   1   │ #!/bin/bash
   2   │ 
   3   │ # Get the current directory or specify the directory as an argument
   4   │ DIR=${1:-.}
   5   │ 
   6   │ # Find all files in the directory (non-recursive)
   7   │ for FILE in "$DIR"/*; do
   8   │     if [ -f "$FILE" ]; then
   9   │         # Extract the base name of the file without the extension
  10   │         BASENAME=$(basename "$FILE")
  11   │         FILENAME="${BASENAME%.*}"
  12   │         
  13   │         # Create a directory named after the file (without the extension)
  14   │         mkdir -p "$DIR/$FILENAME"
  15   │         
  16   │         # Copy/move the file into the newly created directory
  17   │         # cv "$FILE" "$DIR/$FILENAME/"
  18   │         mv "$FILE" "$DIR/$FILENAME/"
  19   │     fi
  20   │ done
