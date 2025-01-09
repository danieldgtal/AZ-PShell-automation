# Define the base name for the files
$baseFileName = "File"

# Loop to create 5 text files
for ($i = 1; $i -le 5; $i++) {
    # Define the file name
    $fileName = "$baseFileName$i.txt"
    
    # Create the file and add some initial content (optional)
    "This is file number $i" | Out-File -FilePath $fileName
    
    # Output a message to confirm file creation
    Write-Host "Created $fileName"
}

Write-Host "All files created successfully."
