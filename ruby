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

Delirant() { local s2 ; while [ -h "$s" ] ; do s2="`readlink "$s"`" ; case "$s2" in [^/]*) s2="`dirname "$s"`/$s2" ;; esac ; s="$s2" ; done ; } ; SCRIPTS() { local s="`command -v "$0"`" ; [ -x "$s" -o ! -x "$0" ] || s="$0" ; case "$s" in */bin/*sh) case "`basename "$s"`" in *.*) true ;; *sh) s="$1" ;; esac ;; esac ; case "$s" in [^/]*) local d="`dirname "$s"`" ; s="`cd "$d" ; pwd`/`basename "$s"`" ;; esac ; Delirant ; s="`dirname "$s"`" ; Delirant ; SCRIPTS="$s" ; } ; SCRIPTS
. "$SCRIPTS/util.sh"

logiciel=ruby

# Historique des versions gérées

v 2.2.3 && prerequis="git pkgconfig \\" && modifs=qsort || true
v 2.2.8 || true
v 2.3.6 || true
v 2.4.3 || true
v 2.5.1 || true

# Variables

v_maj="`echo "$version" | cut -d . -f 1-2`"
archive="https://cache.ruby-lang.org/pub/ruby/$v_maj/ruby-$version.tar.gz"

# Modifications

qsort()
{
	# https://bugs.ruby-lang.org/issues/20151
	# Depuis FreeBSD 14, ils se sont alignés sur GNU, et donc ont à la fois du HAVE_GNU_QSORT_R et du __FreeBSD__
	filtrer util.c sed -E -e '/#if defined HAVE_BSD_QSORT_R|#elif defined HAVE_QSORT_S/s/$/ \&\& !defined HAVE_GNU_QSORT_R/'
}

# En avant!

destiner

prerequis

obtenirEtAllerDansVersion

echo Correction… >&2
for modif in true $modifs ; do $modif ; done

echo Configuration… >&2
./configure --prefix="$dest"

echo Compilation… >&2
make

echo Installation… >&2
sudo make install

sutiliser
