#!/bin/bash
# Assumed that both file1.txt and file2.txt and output.txt are in the same directory as larger.sh file

# Function declaration to count length of common prefix
comlen() {	# Passing two strings as arugments to the function and returning the length of the common prefix between the two strings

    str1="$1"	# Reading the first string arugment	

    str2="$2"	# Reading the second string argument

    len1=${#str1}	# Calculating the length of first string argument

    len2=${#str2}	# Calculating the length of second string arugment

    min_len=$(( len1 < len2 ? len1 : len2 ))	# Calculating the minimum length of the two arguments so as to check for common prefix till this length only
    
    count=0	# Initialiszing the counter for counting the length of common prefix
    for ((i=0; i<min_len; i++)); do	# Iterating over both strings till the minimum length of the two strings to check for common prefix
        if [[ "${str1:i:1}" == "${str2:i:1}" ]]; then	# Condition check for checking whether or not to count the current i'th character for common prefix length
            ((count++))		# If the condition is true then increase the counter to calculate the common prefix length till i'th iteration			
        else	
            break		# If the condition is false then the prefix no longer exists after this i'th character, hence break the loop because the check is over
        fi			# Ending the if conditon
    done			# Ending for loop 

    echo $count			# Return the final counter value which is the final length of common prefix between the two argument strings
}				# Function declaration over


if [[ $# -ne 2 ]]; then		# Check whether the no. of arguments are correctly passed to execute the script
    echo "Usage: $0 <file1> <file2>"	# If not then output the Usage for executing the script
    exit 1	# Exit with status 1 because incorrect input passed, hence the script must not be executed
fi	# Ending If condition

file1="$1"	# Reading the first input file provided as argument
file2="$2"	# Reading the second input file provided as argument


if [[ ! -f "$file1" && ! -f "$file2" ]]; then		# Check if both files provided exist or not in the same directory
	echo "Error: $file1 and $file2 do not exist"	# Outputing that the files do not exist
	echo "create your files using the command cat <filename>.txt"	# Since the files don't exist, outputing the correct usage of creating files before executing the script
	echo "Usage $0 <file1> <file2>"		# Outputing the Usage of how to run the script after creating the argument files
	exit 1		# Exiting with status 1 because the input files provided did not exist hence, the script cannot be executed

elif [[ ! -f "$file1" ]]; then		# Checking if file1 as individual exists or not
    echo "Error: $file1 does not exist." 	# If not then outputing that the file doesn't exist
    echo "create your file using cat <filename>.txt" 	# Outputing the usage to create the file before executing the script
    echo "Usage: $0 <file1> <file2>"	# Outputing the usage to execute the script after creating correct file
    exit 1	# Exiting with status 1 because incorrect input passed hence, the script cannot be executed

elif [[ ! -f "$file2" ]]; then		# Checking if file2 as individual exists or not
	echo "Error: $file2 does not exist"	# If not then outputing that the file doesn't exist
	echo "create your file using cat <filename>.txt" 	# Outputing the usage to create the file before executing the script
	echo "Usage: $0 <file1> <file2>" 	# Outputing the usage to execute the script after creating correct file
	exit 1		# Exiting with status 1 because incorrect input passed hence, the script cannot be executed
fi	# Ending If condition

output_file="out_larger.txt"	# creating a variable to access the output file	
> "$output_file"  # Clearing the output file each time the script is run 

exec 3< "$file1"	# File descriptor for executing/accessing file1
exec 4< "$file2"	# File descriptor for executing/accessing file2

f1len=$(wc -l < "$file1")	# Calculating the size in terms of number of lines of file1
f2len=$(wc -l < "$file2")	# Calculating the size in terms of number of lines of file1


minflen=$(( f1len < f2len ? f1len : f2len ))	# Calculating the minimum number of lines of the two file arguments
maxflen=$(( f1len > f2len ? f1len : f2len ))	# Calculating the maximum number of lines of the two files arguments


for ((i=0; i<minflen; i++)); do 	# Iterating till min length over each line of the two file arguments, as one of the files has reached EOF, hence the common prefix length is 0
    read -r line1 <&3 || line1=""	# Reading the lines from file1 one by one and if no lines are there then, pass empty string
    read -r line2 <&4 || line2=""	# Reading the lines from file2 one by one and if no lines are there then, pass empty string
    
    pref_len=$(comlen "$line1" "$line2")	# Calculating the common prefix length by passing both lines into previously declared function
    echo "$pref_len" >> "$output_file"		# Storing the common prefix length to the output file
done		# Ending the for loop

# Append extra zeroes for unmatched lines
for ((i=minflen; i<maxflen; i++)); do	# Iterating from the min length till the max length as one of the file has reached EOF and hence the common prefix length is 0
    echo 0 >> "$output_file"	# Appending zeros to the output file 
done	# Ending for loop
 
exec 3<&-	# CLosing file descriptors for file1
exec 4<&-	# Closing file descriptors for file2

echo "Output written to $output_file"	# Printing the success message that the output is written to the output file