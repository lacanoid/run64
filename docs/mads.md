Editor64
========
`GET filename,line,dev,sec` - load a text file
`PUT filename,n1-n2,dev,sec` - save a text file
`CPUT` - like `PUT` but with no unnecessary spaces in output file
`AUTO n` - enable auto line numbering with `n` increment
`AUTO` - disable auto line numbering
`FIND/str1/,n1-n2` - find `str1` in line range `n1` to `n2`
`CHANGE/str1/str2/,n1-n2` - replace `str1` with `str2` in line range `n1` to `n2`
`DELETE n1-n2` - delete lines in range `n1` to `n2`
`NUMBER n1,n2,n3` - renumber lines: `n1` = old start number, `n2` = new start number, `n3` = increment
`FORMAT n1-n2` - formatted print lines in range `n1` to `n2`
`KILL` - disable editor
