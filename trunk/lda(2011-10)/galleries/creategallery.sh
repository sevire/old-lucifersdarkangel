#!/bin/bash
HTML_before_anchor="<td width='140' height='130'><font face='Verdana, Arial, Helvetica, sans-serif' size='2'>"
HTML_after_anchor="</font></td>"
HTML_row_begin="<tr align='center' valign='middle'>"
HTML_row_end="</tr>"

ls *.jpg>filelist
i=0

sips -g pixelWidth -g pixelHeight *.jpg > sipsOutput.txt

while read data; do
	if [ ${data:0:3} == "TN_" ]; then
        rowCount=`expr $i % 4`
		if [ $rowCount -eq "0" ] && [ $i != "0" ]; then
			echo $HTML_row_end
		fi
		if [ $rowCount -eq "0" ]; then
			echo $HTML_row_begin
		fi
		echo $HTML_before_anchor"<a href='"$data">"$HTML_after_anchor
    	i=`expr $i + 1`
	fi
done <"filelist"
if [ `expr ${i-1} % 4` != 0 ]; then
		echo $HTML_row_end
fi	