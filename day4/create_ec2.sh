#!/bin/bash

set -euo pipefail

check_awscli(){
    if ! command -v aws &> /dev/null; then
	    echo "AWS CLI is not istalled, please install first"
	    return 1
    fi
}

install_awscli(){
    echo "installing AWS CLI v2 in Linux..."

    #download and install AWS CLI v2 
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    
    #varify installation
    aws --version

    #clean up
    rm -rf awscliv2.zip ./aws 
}

wait_for_instance() {
    local instance_id="$1"

    echo "Waiting for instance $instance_id to be in running state..."

    while true
    do
        status=$(aws ec2 describe-instances \
            --instance-ids "$instance_id" \
            --query "Reservations[0].Instances[0].State.Name" \
            --output text)

        if [[ "$status" == "running" ]]; then
            echo "EC2 instance is running."
            break
        fi

        echo "Current state: $status"
        sleep 10
    done
}


create_ec2_instance(){
    local ami_id="$1"
    local instance_type="$2"
    local key_name="$3"
    local subnet_id="$4"
    local security_group_ids="$5"
    local instance_name="$6"

    
    echo "AMI_ID=$ami_id"
    echo "INSTANCE_TYPE=$instance_type"
    echo "KEY_NAME=$key_name"
    echo "SUBNET_ID=$subnet_id"
    echo "SECURITY_GROUP_IDS=$security_group_ids"
    #Run AWS CLI command to create ec2 instance

    instance_id=$(aws ec2 run-instances \
       --image-id "$ami_id" \
       --instance-type "$instance_type" \
       --key-name "$key_name" \
       --subnet-id "$subnet_id" \
       --security-group-ids "$security_group_ids" \
       --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
       --query 'Instances[0].InstanceId' \
       --output text 
)

    if [[ -z "$instance_id" ]]; then
	    echo "failed to create ec2 instance." >&2
	    exit 2
    fi

    echo "instance $instance_id created successfully."

   #wait for instance to be in running state
   wait_for_instance "$instance_id"

}

main(){

    check_awscli || install_awscli

    echo "Creating EC2 instance..."

    #specify the parameters for creating EC2 instance
    AMI_ID="ami-00cbf6bbdada92e4f"
    INSTANCE_TYPE="t4g.micro"
    KEY_NAME="shell-scripting-for-devops-key"
    SUBNET_ID="subnet-042283be83eeeb881"
    SECURITY_GROUP_IDS="sg-0e069d2db0c737d1a" #add your security group ids seprated by space
    INSTANCE_NAME="Shell-Scirpt-EC2-Demo"

    #call the function to create Ec2 instance
    create_ec2_instance "$AMI_ID" "$INSTANCE_TYPE" "$KEY_NAME" "$SUBNET_ID" "$SECURITY_GROUP_IDS" "$INSTANCE_NAME"

    echo "ec2 instance creation compeleted."


}

# "$@" means that you can use any number of arguments.
main "$@"
