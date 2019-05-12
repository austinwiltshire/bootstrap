#! /bin/sh

ansible-playbook -K --connection=local --inventory 127.0.0.1, playbook.yml
