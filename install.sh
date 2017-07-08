#!/bin/bash

# Which port should Jupyter listen on? (Default: 9999)
PORT=9999

# cd to ~
cd ~

# Get custom domain
echo "Enter your custom domain (i.e. server.siang.ca): "
read DOMAIN

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

# Install tensorflow
pip install --ignore-installed --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.2.1-cp36-cp36m-linux_x86_64.whl

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
xvfb-run -a -s "-screen 0 1400x900x24" jupyter notebook
EOL

# Export conda path
echo "export PATH=~/anaconda3/bin:$PATH" >> ~/.bash_profile

# Run
echo "Installation complete"
echo "Run server with bash ~/notebook.sh"
