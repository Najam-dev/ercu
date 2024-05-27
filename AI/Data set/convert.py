import os
import pandas as pd

# Check the current working directory
current_directory = os.getcwd()
print("Current Working Directory:", current_directory)

# List the files in the current directory
files = os.listdir(current_directory)
print("Files in the current directory:", files)

# Verify if 'test.csv' is in the current directory
if 'test.csv' in files:
    # Load the CSV file
    file_path = 'test.csv'  # Update with your file path if necessary
    data = pd.read_csv(file_path)

    # Remove rows where the 'Action' column is empty or contains only whitespace
    cleaned_data = data[data['Action'].str.strip().astype(bool)]

    # Save the cleaned data to a new CSV file
    cleaned_file_path = 'cleaned_test.csv'  # Update with your desired output path
    cleaned_data.to_csv(cleaned_file_path, index=False)

    print(f"Cleaned file saved to: {cleaned_file_path}")
else:
    print("Error: 'test.csv' not found in the current directory.")
