#!/usr/bin/env python3
import fileinput
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("filename", help="File to search and replace.")
parser.add_argument("search", help="String to search.")
parser.add_argument("replace", help="String to replace.")
args = parser.parse_args()

with fileinput.FileInput(args.filename, inplace=True, backup='.bak') as file:
    for line in file:
        print(line.replace(args.search, args.replace), end='')
