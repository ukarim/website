#!/bin/bash

for f in $(ls *.md)
do
  cmark-gfm --unsafe $f > "${f%.md}.html"
  echo "$f processed"
done

# cmark-gfm can be found at https://github.com/github/cmark-gfm

# visit https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion
# to understand how .md file extension is replaced by .html
