#!/bin/bash

#check out the code latest code from git

git pull

paramscount=$(echo $1 | wc -w)

if [[ $paramscount > 0 ]]; then
	python configFiller.py $1

	if [[ $? ]]; then

        	echo "config file has updated"
	else
        	echo "something went wrong in config file update."
		exit 1
	fi
fi

#changing the ownership
sudo chown testuser:testuser -R /home/testuser/mycode

#creating the tar file
tar --exclude=/home/testuser/mycode/.git -czf /home/testuser/mycode.tar.gz *.*

echo "tar file has been created successfully."

scp /home/testuser/mycode.tar.gz testuser@18.207.216.131:/home/testuser/

ssh testuser@18.207.216.131 "sudo systemctl stop node.service"

ssh testuser@18.207.216.131 "tar -xzvf mycode.tar.gz -C /home/testuser/mycode"

ssh testuser@18.207.216.131 "cd mycode; sudo npm install"

ssh testuser@18.207.216.131 "sudo systemctl start node.service; sudo systemctl status node.service"

sleep 20

status=$(curl -LIs http://18.207.216.131:3000 | grep 200 | wc -l)

if [[ $status > 0 ]]; then

	echo "Site up and running with status code 200"
else 
	echo "Something went wrong to access the site."
	exit 1
fi
