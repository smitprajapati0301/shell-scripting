# `create_ec2.sh` – Line-by-Line Explanation

> This document explains each section of the Bash script used to automate the creation of an AWS EC2 instance.

---

## 1. Shebang

```bash
#!/bin/bash
```

**Explanation**
- `#!` is called the shebang.
- It tells Linux to execute this script using `/bin/bash`.

---

## 2. Enable Strict Mode

```bash
set -euo pipefail
```

**Explanation**
- `-e` Exit if a command fails.
- `-u` Error on undefined variables.
- `pipefail` Pipeline fails if any command fails.

---

## 3. `check_awscli()`

```bash
check_awscli(){
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI is not installed, please install first"
        return 1
    fi
}
```

### Line Explanation

- `check_awscli(){` → Defines a function.
- `command -v aws` → Checks if AWS CLI exists.
- `!` → Executes the block when AWS CLI is missing.
- `&> /dev/null` → Suppresses command output.
- `echo` → Prints an error message.
- `return 1` → Returns failure so the caller can install AWS CLI.

---

## 4. `install_awscli()`

```bash
install_awscli(){
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    aws --version
    rm -rf awscliv2.zip ./aws
}
```

### Line Explanation

- `curl` → Downloads AWS CLI.
- `-o` → Saves the file as `awscliv2.zip`.
- `unzip` → Extracts the installer.
- `sudo ./aws/install` → Installs AWS CLI.
- `aws --version` → Verifies installation.
- `rm -rf` → Cleans temporary files.

---

## 5. `wait_for_instance()`

```bash
local instance_id="$1"
```

Stores the first function argument.

```bash
while true
```

Creates an infinite loop.

```bash
status=$(aws ec2 describe-instances \
    --instance-ids "$instance_id" \
    --query "Reservations[0].Instances[0].State.Name" \
    --output text)
```

Retrieves the EC2 instance state and stores it in `status`.

```bash
if [[ "$status" == "running" ]]; then
```

Checks whether the instance is running.

```bash
sleep 10
```

Waits 10 seconds before checking again.

---

## 6. `create_ec2_instance()`

Arguments:

```bash
local ami_id="$1"
local instance_type="$2"
local key_name="$3"
local subnet_id="$4"
local security_group_ids="$5"
local instance_name="$6"
```

Each variable stores one argument passed into the function.

Debug statements:

```bash
echo "AMI_ID=$ami_id"
echo "INSTANCE_TYPE=$instance_type"
echo "KEY_NAME=$key_name"
echo "SUBNET_ID=$subnet_id"
echo "SECURITY_GROUP_IDS=$security_group_ids"
```

Print the configuration before launching the instance.

Launch command:

```bash
instance_id=$(aws ec2 run-instances \
    --image-id "$ami_id" \
    --instance-type "$instance_type" \
    --key-name "$key_name" \
    --subnet-id "$subnet_id" \
    --security-group-ids "$security_group_ids" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
    --query 'Instances[0].InstanceId' \
    --output text)
```

Option meanings:

- `--image-id` → AMI.
- `--instance-type` → EC2 size.
- `--key-name` → SSH key.
- `--subnet-id` → Target subnet.
- `--security-group-ids` → Attach security groups.
- `--tag-specifications` → Add Name tag.
- `--query` → Return only the Instance ID.
- `--output text` → Plain text output.

Error handling:

```bash
if [[ -z "$instance_id" ]]; then
    echo "failed to create ec2 instance." >&2
    exit 2
fi
```

Checks whether an instance ID was returned.

---

## 7. `main()`

```bash
check_awscli || install_awscli
```

If AWS CLI is missing, install it.

Configuration:

```bash
AMI_ID="..."
INSTANCE_TYPE="..."
KEY_NAME="..."
SUBNET_ID="..."
SECURITY_GROUP_IDS="..."
INSTANCE_NAME="..."
```

Calls:

```bash
create_ec2_instance \
"$AMI_ID" \
"$INSTANCE_TYPE" \
"$KEY_NAME" \
"$SUBNET_ID" \
"$SECURITY_GROUP_IDS" \
"$INSTANCE_NAME"
```

---

## 8. Entry Point

```bash
main "$@"
```

Starts the program and forwards any command-line arguments.

---

# Concepts Learned

- Bash Functions
- Variables
- Local Variables
- Parameters (`$1`, `$2`, ...)
- Command Substitution
- Conditionals
- Loops
- Error Handling
- AWS CLI
- EC2 Automation
- IAM
- VPC
- Security Groups
- Key Pairs
