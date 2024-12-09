#!/usr/bin/env fish

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
    if doctl compute droplet list --format Name --no-header | string match -q -r "^$VPS_NAME\$"
        echo "Deleting VPS $VPS_NAME"
        doctl compute droplet delete --force $VPS_NAME
        check_status "Failed to delete VPS" || return 1
        echo "VPS deleted"
    end
end

# Main script starts here
cleanup_vps || exit 1

# Check if --delete flag is present
if string match -q -- "--delete" $argv
    exit 0
end

echo "Creating VPS $VPS_NAME"

# Get SSH keys
set -l ssh_keys (doctl compute ssh-key list --format ID --no-header)
check_status "Failed to get SSH keys" || exit 1

# Create the droplet
set -l created_droplet_id (doctl compute droplet create \
    --image ubuntu-24-10-x64 \
    --size g-8vcpu-32gb-intel \
    --region ams3 \
    --vpc-uuid 3e8c764a-b075-4573-959d-4e4df9dd55f2 \
    --ssh-keys $ssh_keys \
    --wait \
    --format ID \
    --no-header \
    $VPS_NAME)
check_status "Failed to create VPS" || exit 1
echo "Droplet created with ID $created_droplet_id"


# Get the IP address 
# Need to loop until it shows up (could be a few secs)
echo "Waiting for IP address"
set -l ip_address
set -l iterations 0
set -l max_iterations 30
while test -z "$ip_address"
    set -l output (doctl compute droplet get $created_droplet_id --format PublicIPv4 --no-header)
    check_status "Failed to get IP address" || exit 1
    set ip_address (echo $output | string trim)
    set iterations (math $iterations + 1)
    if test $iterations -gt $max_iterations
        echo "Error: Could not get IP address ($iterations/$max_iterations)" >&2
        exit 1
    end
    sleep 1
end

# Wait until reachable
echo "Waiting for VPS to be reachable"
while not ping -c 1 $ip_address
    sleep 1
end

set -gx VPS_IP $ip_address
echo "IP address: $ip_address (ssh root@\$VPS_IP)"