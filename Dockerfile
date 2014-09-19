FROM ubuntu:latest
MAINTAINER Simon Johansson


# Make sure the repository information is up to date
RUN apt-get update

RUN apt-get install -y ca-certificates wget
# Add the google repos for chrome and talkplugin
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list
RUN echo "deb http://dl.google.com/linux/talkplugin/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# Install OpenSSH
RUN apt-get install -y openssh-server
# Install those sukkas.
RUN apt-get update && apt-get install -y google-chrome-stable google-talkplugin

# Create OpenSSH privilege separation directory
RUN mkdir /var/run/sshd

# Install Pulseaudio
RUN apt-get install -y pulseaudio

# Add the Chrome user that will run the browser
RUN adduser --disabled-password --gecos "Chrome User" --uid 5001 chrome

RUN mkdir /home/chrome/.ssh
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDq5Fhs8EKcobOWnA+6SMoeGBcTpPMaa9jWfaxypbvKmREmZEzVcJEhQFxtAzn4hygve6O4X1qtUJtK3irmLKtwh9wakKbjq1gaGxR52/UgA3ZiHvXTaVZTM7pvPpJ/5a71MNw+QFIeKKifta000Tq3SwZS6WyciFpXm8tI+qGEyHkFLmvaKG+sBz7gvVTZl8T29sJ3M/poHqGGRjQW5A4nKWTHUzSCC9g+myTxWUbNGKspi+kkUGwnYSjYT6vxcQTfFbvDRMEgpvFuSj04GsWf05NLZMVC5naflB/dk6ln/Ibir+wnxYwmCGSoQyGYLLsoHE8DdaIig4cntwybLYxz simon@simonjohansson.com" > /home/chrome/.ssh/authorized_keys
RUN chown -R chrome:chrome /home/chrome/.ssh

# Set up the launch wrapper
RUN echo 'export PULSE_SERVER="tcp:localhost:64713"' >> /usr/local/bin/chrome-pulseaudio-forward
RUN echo 'google-chrome --no-sandbox' >> /usr/local/bin/chrome-pulseaudio-forward
RUN chmod 755 /usr/local/bin/chrome-pulseaudio-forward

# Start SSH so we are ready to make a tunnel
ENTRYPOINT ["/usr/sbin/sshd",  "-D"]

# Expose the SSH port
EXPOSE 22
