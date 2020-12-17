#!/usr/bin/env python3

# https://developer.android.com/studio/command-line/adb#wireless

import os
import sys
import subprocess as sp

from getpass import getpass


def pause():
    print('[Press ENTER to continue]')
    getpass(prompt='')


def step(message):
    print(message)
    pause()


def run_command(command, print_output=False):
    output = sp.check_output(command, shell=True, encoding='utf-8')

    if (print_output):
        print(output)

    return output


# For some reason, without "adb wait-for-device" some scripts fail

def main():
    step('Before continue, remember to connect your phone through USB this time.')

    try:
        run_command("adb kill-server", True)
        run_command('adb wait-for-device && adb tcpip 5555', True)
        ip = run_command("adb wait-for-device && adb shell \"ifconfig | grep -Eo 'inet (addr:)?([0-9]*\\.){3}[0-9]*' | grep -Eo '([0-9]*\\.){3}[0-9]*' | grep -v '127.0.0.1'\"", True)

        step('Now, disconnect the USB cable.')
        run_command(f'adb connect {ip}:5555', True)
        step('DONE!')
    except Exception:
        exc_type, exc_obj, tb = sys.exc_info()

        step(f'ERROR OCURRED! (Line: {tb.tb_lineno})')
        sys.exit(1)


if __name__ == "__main__":
    main()
