# Identify the Network Interface: 
First, you need to know the name of your network interface. Open a terminal on your Ubuntu Server VM and run the following command:
ip a

Look for an interface that's likely connected to your network. Common names are eth0, enp0s3, ensX (where X is a number), or similar. Note down the name of this interface.
enp0s3


# Edit the Network Configuration File: 
List the files in this directory to find the relevant one:
ls /etc/netplan/*.yaml

There might be a single file (like 01-netcfg.yaml or 50-cloud-init.yaml). Open this file using a text editor with sudo privileges (like nano):
sudo nano /etc/netplan/YOUR_FILENAME.yaml

Important: Be very careful when editing YAML files. Indentation is crucial! Use spaces, not tabs.


# Configure the Static IP: 
Inside the YAML file, you'll likely see some existing configuration (possibly for DHCP). You'll need to modify or replace it to set a static IP. Here's a common example of how a static IP configuration might look (adjust the values to match your network):
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:  # Replace 'eth0' with the actual name of your interface
      dhcp4: no
      addresses:
        - 192.168.1.100/24  # Your desired static IP address and subnet mask
      gateway4: 192.168.1.1    # Your network's gateway IP address (usually your router)
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4] # Your desired DNS server addresses


# Explanation of the fields:
ethernets:: Defines the Ethernet interfaces.
eth0:: Replace this with the actual name of your network interface you identified in step 1.
dhcp4: no: Disables DHCP for IPv4 on this interface.
addresses:: A list of IP addresses and their subnet masks. The /24 in the example represents a common subnet mask of 255.255.255.0. Adjust this if your network uses a different subnet.
gateway4:: The IP address of your network's gateway (usually your router). You can often find this information on your host Ubuntu Desktop system's network settings.
nameservers:: Specifies the DNS servers your VM will use to resolve domain names. Google's public DNS servers (8.8.8.8 and 8.8.4.4) are a common choice, but you can use others.


# Apply the New Configuration: 
After you've edited the YAML file, save it and exit the text editor. Then, apply the new network configuration using the following command:
sudo netplan apply

This command tells Netplan to read your configuration and apply the settings.


# Verify the Configuration: 
To check if the static IP address has been successfully assigned, use the ip a command again:
ip a

Look for the network interface you configured (e.g., eth0). You should see the static IP address you assigned listed under it.


# Test Connectivity: 
Finally, test if your VM can communicate with other devices on your network and access the internet. Try pinging your gateway and a public IP address (like Google's DNS):
ping 192.168.1.1
ping 8.8.8.8

If you get replies, your static IP configuration is likely working correctly.


# Important Considerations:
IP Address Conflicts: Make sure the static IP address you choose is within the valid range for your network and is not already being used by another device. Check your router's DHCP settings to see the range it assigns and pick an address outside of that range.
Subnet Mask and Gateway: Ensure the subnet mask and gateway address are correct for your network. These usually match the settings of your host Ubuntu Desktop system.
DNS Servers: Having valid DNS server addresses is crucial for your VM to be able to resolve domain names.
Virtualization Software: The network configuration within your virtualization software (like VirtualBox, VMware, etc.) needs to be set up correctly for your VM to communicate with your host and the network. Typically, using a "Bridged Adapter" network mode in your VM's settings will allow it to get an IP address directly from your router (or you can manually configure one as described above). If you're using other network modes like "NAT" or "Host-only," the configuration steps might be slightly different or you might need to configure port forwarding on your host.
By following these steps, you should be able to manually assign a static IP address to your Ubuntu Server VM. Let me know if you encounter any issues or have further questions!
