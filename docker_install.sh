#!/bin/bash 

sudo apt-get update

dependencies()
   
    { 
        
        sudo apt-get  -y install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

        echo "Adding Docker’s official GPG key"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    }

repo()
  
   {

        sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
   
   }

docker_latest()

   {
     
       sudo apt-get update
       echo "Installing latest docker-ce and docker-ce-cli"
       sudo apt-get install -y docker-ce docker-ce-cli containerd.io
       if [ $? -eq 0 ]; then
        
            echo "Docker installed successfully"
            COUNTER=1
       
       fi
  
   }

adduser_dockergrp()

   {
                 
          sudo usermod -aG docker $(whoami)
          docker version
       
   }


   specific_docker_version()
   
   {
 
        DOCKER_CE=$1
        DOCKER_CE_CLI=$1
        sudo apt-get update
        echo "Installing latest docker-ce and docker-ce-cli"
        sudo apt-get install -y docker-ce=$DOCKER_CE  docker-ce-cli=$DOCKER_CE containerd.io 
        if [ $? -eq 0 ]; then
            
            echo "Docker installed successfully"
            COUNTER=1

        fi
   
   }


echo "Installing dependencies"
dependencies

echo "Adding docker repo"
repo
   
echo -e "Please Select: \n\t 1 for installing latest version \n\t 2 for installing specific version"
read -p "Enter your choice: " CHOICE 

case $CHOICE in 

        1)

          docker_latest
          
          if [ "$COUNTER" -eq 1 ]; then
            
             echo "adding user to docker group"
             adduser_dockergrp
          
          fi
          ;;

        2)
           
          read -p "Please provide docker version: " DOCKER_VERSION 
          
          docker_ver=( $(apt-cache madison docker-ce|awk -F "|" '{print $2}' |grep -i $DOCKER_VERSION) )

          ver=${#docker_ver[@]}

          if [ $ver -eq 1 ]; then

              while :
                do

                    echo "Do you want to install ${docker_ver[@]}  version,type YES/NO"
                    read val

                    case $val in

                       YES|yes|Yes|Y|y)
                                count=1
                                specific_docker_version ${docker_ver[@]}

                                if [ "$COUNTER" -eq 1 ]; then
            
                                    echo "adding user to docker group"
                                    adduser_dockergrp
          
                                fi
                                break
                                ;;
                       NO|no|No|N|n)
                                count=1
                                echo "Bye have a nice day"
                                break
                                ;;
                       *)
                                echo "Please type YES or NO .No other values are valid"
                                ;;
                    esac
                done
          elif [ $ver -ge 2 ]; then

            check=0
            while [ "$check" -eq 0 ]; do

                echo "Matching versions are: "
                printf '%s\n' "${docker_ver[@]}"

                read -p "Please Select one version from abouve value "  docker_choice
                for element in ${docker_ver[@]}; do
                    if [ "$element" == "$docker_choice" ]; then
                            match=1
                            check=1
                            break
                    else
                            match=0

                    fi
                done
            done
            if [ $match -eq 1 ]; then
                while :
                    do

                    echo -n "Do you want to install $docker_ver  version,type YES/NO  "
                    read val

                    case $val in

                        YES|yes|Yes|Y|y)
                                count=1
                                specific_docker_version  $docker_ver
           
                                if [ "$COUNTER" -eq 1 ]; then
            
                                    echo "adding user to docker group"
                                    adduser_dockergrp
          
                                fi
                                break
                                ;;
                        NO|no|No|N|n)
                                count=1
                                echo "Bye have a nice day"
                                break
                                ;;
                        *)
                                echo "Please type YES or NO .No other values are valid"
                                ;;
                    esac
                done
            fi
          else

            echo "couldn't find the provided version"
          
          fi
        ;;
esac

