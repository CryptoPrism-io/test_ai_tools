from datetime import datetime
import csv
import os

# Get current timestamp
now = datetime.now()
timestamp = now.strftime("%Y-%m-%d %H:%M:%S")
day = now.strftime("%d")
month = now.strftime("%m")
year = now.strftime("%y")

print("Hello World")
print(f"Current timestamp: {timestamp}")

# CSV file path
csv_file = "execution_log.csv"

# Check if CSV file exists, if not create with headers
file_exists = os.path.exists(csv_file)

# Write data to CSV
with open(csv_file, 'a', newline='') as file:
    fieldnames = ['timestamp', 'dd', 'mm', 'yy', 'git_action_complete']
    writer = csv.DictWriter(file, fieldnames=fieldnames)
    
    # Write header if file is new
    if not file_exists:
        writer.writeheader()
    
    # Write data row
    writer.writerow({
        'timestamp': timestamp,
        'dd': day,
        'mm': month,
        'yy': year,
        'git_action_complete': 'yes'
    })

print(f"Data logged to {csv_file}")
print(f"Date: {day}/{month}/{year}, Git action complete: yes")