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

# Cheat Sheets

## zsh

### history subsearch

Just press up or down after you've typed a partial command to try and match your command to history

### fzf and zsh 

To use fzf in zsh, append your command line with two ** then press tab. Example:

vi bootstrap/pyt**

Should show the python.yml under /roles/terminal/tasks subdirectory in the bootstrap repo.

### Pycharm

Idea VIM commands can be found here: http://ideavim.sourceforge.net/vim/

I have ,, hooked up to acejump, similar to easy motion.

I have ctrl-p hooked up to Find Anywhere

Sync your settings with your user's settings to get all plugins and keymappings.
