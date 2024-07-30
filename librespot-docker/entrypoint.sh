#!/bin/ash
#An entrypoint script that adds config parameters from all env variables that start with LIBRESPOT_xxx
#And gets a string, such that: $LIBRESPOT_USER=testuser 
#Turns into --user testuser
#And gets appended to it
#It then runs the command given as arguments

command="/usr/bin/librespot"
for var in `env`
do
    if [[ $var =~ ^LIBRESPOT_ ]]; then
        #Get the name of the variable
        name=$(echo "$var" | sed -r "s/LIBRESPOT_(.*)=.*/\1/" | tr '[:upper:]' '[:lower:]')
        #Get the value of the variable
        value=$(echo "$var" | cut -d'=' -f2)

        command="$command --$name $value"
    fi
done
# Print out the command to be run


echo "Running command: $command"
# Run the command
exec $command