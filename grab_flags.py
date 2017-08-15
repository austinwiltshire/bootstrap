# This script can be used to grab a set of flags from a compile_commands.json file and put them in a syntastic friendly
# format. Useful for CMAKE projects that you want to get syntastic working on.

import json
import re

IS_IMPORTANT_FLAG = re.compile('std|^-isystem|^-I')

def grab_flags(command):
    all_flags = command.split()
    important_flags = set()
    for flag in all_flags:
        if IS_IMPORTANT_FLAG.search(flag):
            important_flags.add(flag)
    return important_flags

IMPORTANT_FLAGS = set()
for command_json in json.load(open("./build/compile_commands.json")):
    IMPORTANT_FLAGS.update(grab_flags(command_json['command']))

syntastic_file = open(".syntastic_cpp_config", "w")
for flag in IMPORTANT_FLAGS:
    syntastic_file.write(flag + "\n")

syntastic_file.close()

