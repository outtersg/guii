#!/bin/sh
# Copyright (c) 2006 Guillaume Outters
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

absolutiseScripts() { SCRIPTS="$1" ; echo "$SCRIPTS" | grep -q ^/ || SCRIPTS="`dirname "$2"`/$SCRIPTS" ; } ; absolutiseScripts "`command -v "$0"`" "`pwd`/." ; while [ -h "$SCRIPTS" ] ; do absolutiseScripts "`readlink "$SCRIPTS"`" "$SCRIPTS" ; done ; SCRIPTS="`dirname "$SCRIPTS"`"
. "$SCRIPTS/util.sh"

logiciel=flex

# Historique des versions gérées

v 2.5.39 && modifs="" || true
v 2.6.3 || true
v 2.6.4 && modifs="reallocarray" || true

prerequis

# Modifications

reallocarray()
{
	# https://github.com/westes/flex/issues/219
	# https://github.com/westes/flex/issues/265
	export CPPFLAGS="$CPPFLAGS -D_GNU_SOURCE"
}

# Variables

dest="$INSTALLS/$logiciel-$version"
archive="http://cznic.dl.sourceforge.net/project/flex/flex-$version.tar.bz2"
archive="https://github.com/westes/flex/releases/download/v$version/flex-$version.tar.gz"

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
