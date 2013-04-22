# patch16 -- ROM header patcher/reader

A tool for adding/modifying/querying the header of a ROM file.

Patching a ROM with a header will replace the existing header.

Options for patching:
    -o : output file name
    -v, --version: spec version
    -s, --start: start address (decimal)

Options for verifying:
    -c, --check: check the header/rom are valid

Other options:
    -r, --raw: if a header exists, remove it
    -h, --help: display help
