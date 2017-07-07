#!/bin/bash

# Enter variables
DOMAIN="your.domain.name"
PORT=9999

# Fix unable to resolve host
echo $(hostname -I | cut -d\  -f1) $(hostname) | sudo tee -a /etc/hosts

# Update repos
sudo apt-get -y update
sudo apt-get -y upgrade

# Install anaconda
wget https://repo.continuum.io/archive/Anaconda3-4.4.0-Linux-x86_64.sh
bash Anaconda3-4.4.0-Linux-x86_64.sh -b
export PATH=~/anaconda3/bin:$PATH

# For gym
sudo apt-get install -y python-numpy python-dev cmake zlib1g-dev libjpeg-dev xvfb libav-tools xorg-dev python-opengl libboost-all-dev libsdl2-dev swig

# Install gym
pip install 'gym[all]'

# Install JS Animation
# http://nbviewer.jupyter.org/github/patrickmineault/xcorr-notebooks/blob/master/Render%20OpenAI%20gym%20as%20GIF.ipynb
git clone https://github.com/jakevdp/JSAnimation
cd JSAnimation
python setup.py install
cd ~

# Install Let's Encrypt
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y certbot
sudo certbot certonly --standalone -d $DOMAIN

sudo cp -rL /etc/letsencrypt/live/$DOMAIN/ /home/~keys

# Config Jupyter
jupyter notebook --generate-config
jupyter notebook password

# Add the following to the config:
cat > ~/.jupyter/jupyter_notebook_config.py << EOL
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
c.NotebookApp.port = ${PORT}
c.NotebookApp.certfile = u'/home/~keys/fullchain.pem'
c.NotebookApp.keyfile = u'/home/~keys/privkey.pem'
EOL

cd ~
mkdir notebook

cat > ~/notebook.sh << EOL
cd ~/notebook
xvfb-run -a -s \"-screen 0 1400x900x24\" jupyter notebook
EOL

echo "Installation complete"
echo "Run with bash notebook.sh"
