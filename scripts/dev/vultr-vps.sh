#!/usr/bin/env fish

function envsource
  for line in (cat $argv | grep -v '^#')
    set item (string split -m 1 '=' $line)
    set -gx $item[1] $item[2]
    echo "Exported key $item[1]"
  end
end
set -l DIR (dirname (status -f))
envsource $DIR/../../.env

set -g VPS_NAME nixos-test

# Function to check command status and exit if failed
function check_status
    if test $status -ne 0
        echo "Error: $argv[1]" >&2
        return 1
    end
end

# Function to clean up existing VPS
function cleanup_vps
    # Check if VPS exists
    set -l instance_list (vultr-cli instance list --output json | jq -r '.instances[] | select(.label == "'$VPS_NAME'") | .id')
    if test -n "$instance_list"
        echo "Deleting VPS $VPS_NAME"
        vultr-cli instance delete $instance_list
        check_status "Failed to delete VPS" || return 1
        echo "VPS deleted"
        # Wait a moment to ensure deletion is processed
        sleep 5
    end
end

# Main script starts here
cleanup_vps || exit 1

# Check if --delete flag is present
if string match -q -- "--delete" $argv
    exit 0
end

echo "Creating VPS $VPS_NAME"

# Get SSH key ID for OrvarPro
set -l ssh_key_id (vultr-cli ssh-key list --output json | jq -r '.ssh_keys[] | select(.name == "OrvarPro") | .id')
check_status "Failed to get SSH key ID" || exit 1

if test -z "$ssh_key_id"
    echo "Error: Could not find SSH key 'OrvarPro'" >&2
    exit 1
end

# Create the instance
set -l instance_creation_output (vultr-cli instance create \
    --region sto \
    --plan "vhp-8c-16gb-amd" \
    --os 1743 \
    --host $VPS_NAME \
    --label $VPS_NAME \
    --ssh-keys $ssh_key_id \
    --output json)

check_status "Failed to create VPS" || exit 1

set -l created_instance_id (echo $instance_creation_output | jq -r '.instance.id')

if test -z "$created_instance_id"
    echo "Error: Failed to get instance ID from creation response" >&2
    echo "Response was: $instance_creation_output" >&2
    exit 1
end

echo "Instance created with ID $created_instance_id"

# Get the IP address
echo "Waiting for IP address"
set -l ip_address
set -l iterations 0
set -l max_iterations 30
while test -z "$ip_address"
    set -l instance_data (vultr-cli instance get $created_instance_id --output json)
    check_status "Failed to get instance data" || exit 1
    
    set -l main_ip (echo $instance_data | jq -r '.instance.main_ip')
    if test -n "$main_ip" -a "$main_ip" != "0.0.0.0" -a "$main_ip" != "null"
        set ip_address $main_ip
    end
    
    set iterations (math $iterations + 1)
    if test $iterations -gt $max_iterations
        echo "Error: Could not get IP address after $max_iterations attempts" >&2
        exit 1
    end
    sleep 2
end

# Wait until reachable
echo "Waiting for VPS to be reachable"
set -l ping_iterations 0
set -l max_ping_iterations 30
while not ping -c 1 -W 1 $ip_address >/dev/null 2>&1
    set ping_iterations (math $ping_iterations + 1)
    if test $ping_iterations -gt $max_ping_iterations
        echo "Warning: VPS not responding to ping after $max_ping_iterations attempts" >&2
        break
    end
    sleep 2
end

set -gx VPS_IP $ip_address
echo "IP address: $ip_address (ssh root@\$VPS_IP)"