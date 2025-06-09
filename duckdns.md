# Part 1: Set up a DuckDNS Account and Domain

Go to the DuckDNS Website: Open your web browser and go to https://www.duckdns.org/.

Log In: You can log in using your existing Google, GitHub, Twitter, or Reddit account. Choose the one you prefer.

Add a Domain: Once logged in, you'll see a section to add domains.

In the "sub domain" field, type the hostname you want (e.g., myrpi5).
Choose a DuckDNS domain from the dropdown (e.g., .duckdns.org). So your full hostname would be myrpi5.duckdns.org.
Click "add domain".
If the subdomain is available, it will be added to your list.
Note Your Token: On the DuckDNS main page, you'll see your domains listed. Above them, there will be a section that says "your token is:" followed by a long string of letters and numbers. Copy this token down, as you'll need it for the script on your Raspberry Pi. Keep this token secret!

# Part 2: Configure the DuckDNS Client on your Raspberry Pi

## SSH into your Raspberry Pi:

ssh your_username@your_rpi_internal_ip

## Create a DuckDNS directory:

mkdir -p ~/duckdns
cd ~/duckdns

## Create the update script:

nano duck.sh

### Paste the following content into the file. Replace YOUR_DUCKDNS_DOMAIN with the hostname you chose (e.g., myrpi5) and YOUR_DUCKDNS_TOKEN with your actual token from the DuckDNS website. 

echo url="https://www.duckdns.org/update?domains=modulo-0&token=c9689d7b-bf0c-4f88-819d-938ce28b7ff2&ip=" | curl -k -o ~/duckdns/duck.log -K -

## Make the script executable:

chmod 700 duck.sh

## Test the script:

./duck.sh


### Check the log file

cat ~/duckdns/duck.log

# Part 3: Automate the Update with Cron

## Edit your crontab:

crontab -e

## Add the cron job (Add the following line at the end of the file. This tells cron to run the duck.sh script every 5 minutes):

*/5 * * * * /home/modulo/duckdns/duck.sh >/dev/null 2>&1

# Part 4: Update your Port Forwarding and Remote Access Details

Now that DuckDNS is set up and your Pi is updating your hostname, you can stop using the numeric public IP.

Port Forwarding on your Router:

The port forwarding rules you set up on your router still need to use your Raspberry Pi's internal LAN IP address (e.g., 192.168.1.100). The router's public IP (the 84.121.136.108 you found earlier) is what DuckDNS will point to.
Remote Access from your Phone/Computer:

For SFTP: In FileZilla, Termius, or your chosen SFTP client, change the "Host" or "Server" field from 84.121.136.108 to your new DuckDNS hostname (e.g., myrpi5.duckdns.org). Keep the port as 2222.
For Airflow UI: In your web browser, change the URL from http://84.121.136.108:8080 to http://myrpi5.duckdns.org:8080.
That's it! Now, even if your home's public IP address changes, DuckDNS will ensure that myrpi5.duckdns.org always points to your current IP, and your remote access will continue to work seamlessly.