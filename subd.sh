#!/bin/bash

read -p "Enter the input file name containing wildcard domains: " input_file

# File name

subdomains_file="subdomains.txt"
alivesubdomains_file="alivesubdomains.txt"
all_urls_file="all-url.txt"
all_alive_paths_file="all-alivepaths.txt"

# Perform subdomain enumeration and save the results
cat "$input_file" | while read -r domain; do
	echo "Enumerating subdomains for $domain"
	subfinder -d "$domain" >> "$subdomains_file"
	assetfinder --subs-only "$domain" >> "$subdomains_file"
done

# Use Filter and verify the status of subdomains using httpx

cat "$subdomains_file" | httpx -silent -status-code -o "$alivesubdomains_file"

# Use waybackurls agains the alive subdomains and save 

cat "$alivesubdomains_file" | waybackurls >> "$all_urls_file"

# Perform mass directory bruteforcing on each subdomain

extensions=".php,.txt,.jsp,.aspx,.zip,.sql,.bak,.js,.json,.html"

while read -r subdomain; do
	echo "Running directory bruteforce on $subdomain"
	ffuf -w files.txt -u "https://$subdomain/FUZZ$extensions"
done < "$alivesubdomains_file"

