# bootstrap
Get my dev environment going from nothing

To use this repo, you can use the vagrantfile (currently geared towards hyperv)
or just run this in either a WSL or Ubuntu 18 environment (tested in WSL Ubuntu 18, but not
tested on raw ubuntu 18).

git clone https://github.com/austinwiltshire/bootstrap.git &&
cd bootstrap &&
sudo apt-get update &&
sudo apt-get install ansible --yes &&
ansible-galaxy install -r requirements.yml &&
ansible-playbook -K --connection=local --inventory 127.0.0.1, playbook.yml
