# ZARA.py
# This script processes a dataset from Zara, focusing on cleaning and preparing the data for analysis.
import pandas as pd  # type: ignore

# Read the CSV file with error handling
try:
    df = pd.read_csv('zara.csv')
    # Show the first few rows
    print("First few rows of the dataset:")
    print(df.head())
except FileNotFoundError:
    print("Error: The file 'zara.csv' was not found.")
    exit()
except pd.errors.EmptyDataError:
    print("Error: The file 'zara.csv' is empty.")
    exit()
except Exception as e:
    print(f"An unexpected error occurred: {e}")
    exit()

#####################################################################
# Data Preprocessing
try:
    # Check for missing values
    print("\nMissing values in each column:")
    print(df.isnull().sum())

    # Drop Rows with Missing 'name' or 'description'
    if 'name' not in df.columns or 'description' not in df.columns:
        raise KeyError("Required columns 'name' or 'description' are missing in the dataset.")
    df_clean = df.dropna(subset=['name', 'description'])

    # Convert Data Types
    if 'scraped_at' in df.columns:
        df['scraped_at'] = pd.to_datetime(df['scraped_at'], errors='coerce')
    if 'price' in df.columns:
        df['price'] = pd.to_numeric(df['price'], errors='coerce')

    # Standardize Categorical Columns
    for col in ['Promotion', 'Seasonal', 'Product Position', 'Product Category']:
        if col in df.columns:
            df[col] = df[col].str.lower().str.strip()

    # Check Unique Values in Categorical Columns and Their Counts
    def display_unique_product_attributes_with_counts(df_clean):
        for column in ['Product Position', 'Promotion', 'Product Category', 'Seasonal']:
            if column in df_clean.columns:
                unique_values = df_clean[column].value_counts()
                print(f"\nUnique values and counts for '{column}':\n{unique_values}")
            else:
                print(f"\nColumn '{column}' is missing in the dataset.")

    display_unique_product_attributes_with_counts(df_clean)

except KeyError as e:
    print(f"KeyError: {e}")
except Exception as e:
    print(f"An error occurred during preprocessing: {e}")

df_clean.to_csv('zara.csv', index=False)
print("Cleaned data has replaced the original file 'zara.csv'.")
# The cleaned data is saved to 'zara.csv' for further analysis.
# The script handles missing values, converts data types, and standardizes categorical columns.
# It also checks for unique values in specific columns and prints them out.
import pandas as pd # type: ignore
from datetime import datetime

# Mock data for testing
data = {
    'name': ['Item1', 'Item2', 'Item3'],
    'description': ['Desc1', 'Desc2', 'Desc3'],
    'price': [10.5, 20.0, 15.0],
    'scraped_at': ['2023-01-01', '2023-01-02', '2023-01-03']
}
df = pd.DataFrame(data)

# Drop rows with missing 'name' or 'description'
df_clean = df.dropna(subset=['name', 'description'])

# Save the cleaned data with gzip compression and include a timestamp in the filename

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
output_filename = f'cleaned_data_{timestamp}.csv.gz'
df_clean.to_csv(output_filename, index=False, compression='gzip')
print(f"Cleaned data saved to '{output_filename}'.")