#!/bin/bash

# Assuming that the order of inputs is followed i.e. first file must be logs file, second must be output and third must be timestamp file
# Assuming that the device on which the script is run, has enough space to create a temporary file, which will be deleted after script execution but is mandatory for script execution
# Assuming that the logs.csv file doesn't have a header which explains the titles of the data in it and that the header description mentioned in the assignment is like a comment for understanding purposes and is not actually present in the logs.csv file
# If the header is present in the logs.csv file, then assumed that the first line is the header and one line is empty before the data, hence to read them, use awk "NR>2" logs.csv and pipe it at starting to the unique ip extraction line


if [[ $# -ne 3 ]]; then 	# Checking if correct no. of arguments are passed as input
	echo "Usage : $0 <inputFile> <outputFile> <timestampFile>"	# If not then outputing the usage of how to execute the script
	exit 1	# Exiting with status 1 as incorrect input passed, hence the script cannot be executed
fi	# Ending if condintion

file1="$1"	# Reading the first argument as file1
output_file="$2"	# Reading the second argument as output file
ts_file="$3" 	# Reading the third argument as timestamp file

if [[ ! -f "$file1" || ! -f "$output_file" || ! -f "$ts_file" ]]; then		# Checking if the argument files exist or not in the same directory
    echo "Error: Some files do not exist. Please ensure that the provided files are created"	# If not, Outputing that files don't exist
    echo "Usage: $0 <inputFile> <outputFile> <timestampFile>" 		# Outputing the usage of how to execute the script
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Input file not detected" > "$ts_file"	# Outputing Input file not detected to the timestamp file
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Script execution failed due to invalid input" >> "$ts_file"	# Outputing script execution failed to the timestamp file
    exit 1	# Exiting with status 1 as incorrect inputs passed, hence script cannot be executed
fi	# Ending If condition

echo "$(date '+%Y-%m-%d %H:%M:%S') - Input files exist" > "$ts_file" 	# Outputing Input files exist to the timestamp file

awk -F, '{print $1}' "$file1" | sort | uniq > "$output_file"	# Using awk to get the first column of ip addresses, then sorting them and then using uniq to get the unique ip's and then outputing them to output file

echo "$(date '+%Y-%m-%d %H:%M:%S') - Unique IP extraction completed" >> "$ts_file" # Outputing Unique ip extraction completed to the timestamp file

echo "-----x-----x-----" >> "$output_file"	# appending the ending delimiter to the output file to show the scope of unique ip output

getCount=$(awk -F, '{print $3}' "$file1" | grep -c "GET")	# Calculating the number of GET requests using grep from column 3 using awk 
postCount=$(awk -F, '{print $3}' "$file1" | grep -c "POST")	# Calculating the number of POST requests using grep from column 3 using awk
dltCount=$(awk -F, '{print $3}' "$file1" | grep -c "DELETE")	# Calculating the number of DELETE requests using grep from column 3 using awk
putCount=$(awk -F, '{print $3}' "$file1" | grep -c "PUT")	# Calculating the number of PUT requests using grep from column 3 using awk

freq=$(mktemp)	# Creating a temporary frequency file to be used to implement sort to display top 3 HTTP methods

echo "$getCount GET" >> "$freq"		# Appending the GET request along with it's fequency of calls to temp frequency file
echo "$postCount POST" >> "$freq"	# Appending the POST request along with it's frequency of calls to temp frequency file
echo "$dltCount DELETE" >> "$freq"	# Appending the DELETE request along with it's frequency of calls to temp frequency file
echo "$putCount PUT" >> "$freq" 	# Appending the PUT request along with it's frequency of calls to temp frequency file

awk '{print}' "$freq" | sort -k1,1nr -k2,2 | awk 'NR<=3' >> "$output_file" 	# Sorting the temp freq file first wrt frequency and then wrt alphabetical order to show top 3 HTTP methods

rm "$freq" 	# Removing the temp freq file since it's usage is done
echo "$(date '+%Y-%m-%d %H:%M:%S') - Top 3 HTTP methods identified" >> "$ts_file"	# Appending the Top 3 HTTP methods identified to the timestamp file
echo "-----x-----x-----" >> "$output_file"	# appending the ending delimeter to the output file to show the scope of Top methods output


hrs=( "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" ) 	# Declaring the hours list
ctrhr=() 	# Declaring the empty list for storing the count of requests made in that hour
for i in {0..23}; do 	# interating over the no. of hours to count the no. of requests made in that hour
	count=$(awk -F, '{print $2}' "$file1" | awk '{print $2}' | awk -F':' '{print $1}' | grep -c ${hrs[i]}) 	# using multiple piped awks to navigate through different columns based on the delimeters like first awk for comma, second awk for spaces, third awk for ":" and then using grep to get hour requests

	ctrhr+=("$count") 	# incrementing the counter to store the correct no. of requests made for i'th hour
done	# Ending for loop

for i in {0..23}; do	# Iterating over the count of requests to store them in the output file according to the hour and the requests made in that hour
	echo "Hour $i: ${ctrhr[i]}" >> "$output_file" 	# Appending to the output file the Hour and the no. of requests made in that hour
done	# Ending for loop
echo "$(date '+%Y-%m-%d %H:%M:%S') - Hourly request count completed" >> "$ts_file" 	# Appending to the timestamp file, Hourly request count completed
echo "-----x-----x-----" >> "$output_file" 	# appending the ending delimeter to the output file to show the scope of hourly request count output
echo "$(date '+%Y-%m-%d %H:%M:%S') - Script execution completed" >> "$ts_file" 	# Appending to the timestamp file that script execution is completed
echo "Output written to ${output_file}" 	# Outputing success message that output is written to output file