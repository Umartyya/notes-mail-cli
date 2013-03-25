# notes-mail-cli

A simple Lotus Notes mail client on the command line.

## Prerequisites

* Lotus Notes installed (probably also configured to use an id file)
* JRE 6 (or later) installed
* Lotus Notes installation folder in PATH
* notes.jar in CLASSPATH

## Additional prerequisites for Linux

* Ensure that environment variable LD_LIBRARY_PATH is exported with the notes folder as its value. (Eg: export LD_LIBRARY_PATH=/opt/ibm/lotus/notes)

## Currently available tasks

* Check all mail
* Set one (or all) mail as read

## Usage

Run run.rb in the bin folder to start the application. The section below describes the list of available switches.

If none is provided, the application will check for existence and validity of "config.yaml" in the working folder. If both are true, the application will use it. If not, it will prompt to create a valid config and exit.

### List of command line switches

* -h | --help

Shows help file

* -c | --create-config (FILE)

Creates a config file FILE in the working folder. If FILE is not supplied, defaults to "config.yaml".

* -u | --use-config FILE

Uses the config file FILE.

* -p | --password PASSWORD

Can

## Simple troubleshooting

### Error: lsxbe (Not found in java.library.path)
In Linux, locate the folder containing the file "liblsxbe.so" (usually in /opt/ibm/lotus/notes). Ensure that the environment variable LD_LIBRARY_PATH is available and is set to that folder path.


