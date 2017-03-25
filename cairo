#!/bin/sh
# Copyright (c) 2005 Guillaume Outters
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e

absolutiseScripts() { SCRIPTS="$1" ; echo "$SCRIPTS" | grep -q ^/ || SCRIPTS="`dirname "$2"`/$SCRIPTS" ; }
calcScripts() { absolutiseScripts "`command -v "$1"`" "`pwd`/." ; while [ -h "$SCRIPTS" ] ; do absolutiseScripts "`readlink "$SCRIPTS"`" "$SCRIPTS" ; done ; SCRIPTS="`dirname "$SCRIPTS"`" ; }
calcScripts "$0"
. "$SCRIPTS/util.sh"

logiciel=cairo

v 1.12.8 && prerequis="pixman >= 0.22 glib libpng" || true
v 1.12.14 && prerequis="pixman >= 0.30 glib libpng" || true
v 1.12.16 && prerequis="pixman >= 0.30 glib libpng" || true
v 1.12.18 || true
v 1.14.8 && prerequis="$prerequis freetype fontconfig" || true # freetype pour éviter le "use of undeclared identifier 'cairo_ft_font_face_create_for_pattern'".

prerequis

archive=http://cairographics.org/releases/cairo-$version.tar.xz

dest=$INSTALLS/$logiciel-$version

[ -d "$dest" ] && exit 0

obtenirEtAllerDansVersion

echo Correction… >&2
for modif in true $modifs ; do $modif ; done

echo Configuration… >&2
./configure --prefix="$dest"

echo Compilation… >&2
make

echo Installation… >&2
sudo make install
sutiliser "$logiciel-$version"

rm -Rf $TMP/$$
