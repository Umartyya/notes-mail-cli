# notes-mail-cli

A simple Lotus Notes mail client on the command line.

## Prerequisites

* Lotus Notes installed
* JRE 6 (or later) installed
* Lotus Notes installation folder in PATH
* notes.jar in CLASSPATH

## Additional prerequisites for Linux

* Ensure that environment variable LD_LIBRARY_PATH is exported with the notes folder as its value. (Eg: export LD_LIBRARY_PATH=/opt/ibm/lotus/notes)

## Currently available tasks

* Check all mail
* Set one (or all) mail as read

## Simple troubleshooting

### Error: lsxbe (Not found in java.library.path)
In Linux, locate the folder containing the file "liblsxbe.so" (usually in /opt/ibm/lotus/notes). Ensure that the environment variable LD_LIBRARY_PATH is available and is set to that folder path.


