#!/bin/bash

# grab the list of applets to package from the list.conf.
list=`sed -n "/^\[.*\]/p" list.conf | tr -d "[]"`

if test -d FTP; then
	echo "You have to remove FTP directory"
	exit 1
else
	mkdir FTP
	cp list.conf FTP
	for f in $list; do
		test ! -e "$f/auto-load.conf" && continue
		
		echo "make $f"
		# remove unwanted files.
		rm -f "$f/*.pyc" "$f/*~"
		
		# check that the version in both .conf are identical.
		version1=`grep "^version *= *" "$f/auto-load.conf" | sed "s/.*= *//g"`
		version2=`head -1 "$f/$f.conf" | tr -d "#"`
		if test "$version1" != "$version2"; then
			echo "  Warning: versions mismatch for $f ($version1/$version2)"
		fi
		
		# build the tarball.
		tar cfz "$f.tar.gz" "$f" --exclude="last-modif" --exclude="preview.png"
		
		# place it in its folder.
		mkdir "FTP/$f"
		mv "$f.tar.gz" "FTP/$f"

		# add preview
		cp "$f/preview" "FTP/$f"

		# add description
		grep "^description *= *" "$f/auto-load.conf" | sed "s/.*= *//g" > "FTP/$f/readme"

		# add dependences
		test -f "$f/dependences.txt" && cp "$f/dependences.txt" "FTP/$f/dependences"
	done;
	
	# build language tree
	./make_locale.sh 1
fi

exit 0
