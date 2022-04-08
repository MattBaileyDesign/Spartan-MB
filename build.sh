#!/bin/sh

# -------------------------------------------------------------------
# UPDATE THIS VARIABLE ----------------------------------------------

# thisFont="Spartan" # must match the name in the font file, e.g. FiraCode-VF.ttf needs the variable "FiraCode"

# -------------------------------------------------------------------
# Update the following as needed ------------------------------------
set -e


echo "Generating VFs"
# mkdir -p ./fonts/variable
fontmake -g source/Spartan.glyphs -o variable --round-instances --output-path ./fonts/Spartan\[wght\].ttf



echo "Generating Statics" ##run fixes on statics as well. 

fontmake -g source/Spartan.glyphs -o ttf --round-instances -a --keep-direction -i --output-dir ./fonts/static/


echo "Statics Built" ##run fixes on statics as well. 

echo "Removing Build UFOS"

rm -rf master_ufo/ instance_ufo/

echo "Build UFOS Removed"

echo "Post processing"

vfs=$(ls ./fonts/*.ttf)
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	gftools fix-nonhinting $vf "$vf.fix";
	mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=./fonts/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm ./fonts/*.ttx
done
rm ./fonts/*backup*.ttf


stat=$(ls ./fonts/static/*.ttf)
for st in $stat
do
	gftools fix-dsig -f $st;
	gftools fix-hinting $st; #if this doesn't work rename as done above and figure diff solution.
	mv "$st.fix" $st;
	ttx -f -x "MVAR" $st; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $st)
	new_file=./fonts/static/$rtrip.ttx;
	rm $st;
	ttx $new_file
	rm ./fonts/static/*.ttx
done
# rm ./fonts/vf/static/*backup*.ttf





echo "fix vf meta? ok let's try that. I'm trying to fix VF meta"
gftools fix-vf-meta $vfs;
for vf in $vfs
do
	mv "$vf.fix" $vf;
done

echo "Post processing complete"

# echo "running fb"
# fontbakery check-googlefonts ./fonts/vf/*.ttf --ghmarkdown SpartanChecks.md 
# echo "finish vf check"
# echo "show dir now run static fb checks"
# fontbakery check-googlefonts ./fonts/vf/static/*.ttf --ghmarkdown SpartanStaticChecks.md
# echo "fb checks done"
