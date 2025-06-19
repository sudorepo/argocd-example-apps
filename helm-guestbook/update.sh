# Get the current date and time in the exact YYYY-MM-DD HH:MM:SS format
# Current time in Lisbon, Portugal is 2025-06-19 20:44:34 WEST
CURRENT_DATE=$(date +"%Y-%m-%d %H:%M:%S")

# Use sed to find the line that contains 'response_date ='
# and then, on *that specific line*, substitute the date pattern with the new date.
sed -i "/response_date = '/s/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}/$CURRENT_DATE/" server.py

echo "Attempted to update date in server.py to: $CURRENT_DATE"

# Optional: Display the relevant line to confirm the change (macOS users might need 'gsed')
echo "--- Current state of the line in server.py ---"
grep "response_date =" server.py