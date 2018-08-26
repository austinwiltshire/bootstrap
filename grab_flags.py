"""This script can be used to grab a set of flags from a
compile_commands.json file and put them in a syntastic friendly
format. Useful for CMAKE projects that you want to get syntastic working on."""

import json
import re
import shutil
import os

IS_IMPORTANT_FLAG = re.compile('std|^-isystem|^-I')

def grab_flags(command):
    """Grabs all include and warning flags from a line from
    compile_commands.json files"""
    all_flags = command.split()
    important_flags = set()
    for flag in all_flags:
        if IS_IMPORTANT_FLAG.search(flag):
            important_flags.add(flag)
    return important_flags

IMPORTANT_FLAGS = set()
for command_json in json.load(open("./build/compile_commands.json")):
    IMPORTANT_FLAGS.update(grab_flags(command_json['command']))

SYNTASTIC_FILE = open(".syntastic_cpp_config", "w")
for syntastic_flag in IMPORTANT_FLAGS:
    SYNTASTIC_FILE.write(syntastic_flag + "\n")

SYNTASTIC_FILE.close()

# TO USE:
# add
# source .neomake_cpp_config.vimrc
# to a directory local .lvimrc file
# must be used with local vimrc plugin
# https://github.com/embear/vim-localvimrc
NEOMAKE_FILE = open(".neomake_cpp_config.vimrc", "w")
for neomake_flag in IMPORTANT_FLAGS:
    NEOMAKE_FILE.write("call add(g:neomake_cpp_gcc_maker['args'], \"{0}\")\n"
        .format(neomake_flag)
    )
NEOMAKE_FILE.close()

#YCM setup
#copy the base file into the current directory
shutil.copy(os.path.expanduser("~") + "/.vim/.ycm_extra_conf.py", ".")

#grab the likely compile database location. user can edit this in the json file
#or we can make this smarter to search for the compile-commands database ourselves
ycm_conf = {'compile_commands_database' : os.path.abspath(".") + "/build"}
json.dump(ycm_conf, open("ycm_conf.json", "w"))
