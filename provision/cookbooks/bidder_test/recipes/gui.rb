# encoding: utf-8

package 'python-software-properties'

bash 'install gnome3' do
  code <<-CODE
    add-apt-repository ppa:gnome3-team/gnome3-next
    add-apt-repository ppa:gnome3-team/gnome3
    apt-get update
  CODE
end

package 'gnome-shell'
package 'ubuntu-gnome-desktop'

#package 'virtualbox-guest-additions-iso'
#
#bash 'install all guest additions' do
#  code <<-CODE
#    mkdir -p /media/iso
#    umount /media/iso || /bin/true
#    mount -o loop,ro /usr/share/virtualbox/VBoxGuestAdditions.iso /media/iso 
#    cd /media/iso
#    ./VBoxLinuxAdditions.run || /bin/true
#  CODE
#end
