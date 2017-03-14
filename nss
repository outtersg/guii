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

logiciel=nss

# Historique des versions gérées

v 3.29.3 && v_nspr="4.13.1" && prerequis="nspr $v_nspr" && modifs="pasGcc unistd alertesZlib" || true

# Modifications

pasGcc()
{
	filtrer coreconf/`uname`.mk sed -e 's/gcc/cc/g' -e 's/g\+\+/c++/g'
}

unistd()
{
	filtrer lib/zlib/gzguts.h sed -e '/include <stdio/a\
#include <unistd.h>
'
}

alertesZlib()
{
	# https://github.com/madler/zlib/pull/112
	filtrer lib/zlib/inflate.c sed -e 's/-1L << 16/-(1L << 16)/g'
}

configure()
{
	echo "INCLUDES += -I$destnspr/include/nspr" >> coreconf/`uname`.mk
	echo "INCLUDES += $CFLAGS" >> coreconf/`uname`.mk 
	echo "DSO_LDOPTS += $LDFLAGS" >> coreconf/`uname`.mk
	echo "MK_SHLIB += $LDFLAGS" >> coreconf/`uname`.mk
}

install()
{
	prefixeObj="`uname`"
	rm -Rf dest
	cp -R -L "`ls -d ../dist/$prefixeObj*.OBJ | tail -1`" dest # bin et lib
	cp -R -L "../dist/public" dest/include # include
	mkdir dest/lib/pkgconfig
	sed \
		-e "s#%prefix%#$dest#g" \
		-e "s#%exec_prefix%#$dest/bin#g" \
		-e "s#%libdir%#$dest/lib#g" \
		-e "s#%includedir%#$dest/include#g" \
		-e "s#%NSS_VERSION%#$version#g" \
		-e "s#%NSPR_VERSION%#$v_nspr#g" \
		< pkg/pkg-config/nss.pc.in > dest/lib/pkgconfig/nss.pc
	sudo rm -Rf "$dest"
	sudo cp -R dest "$dest"
}

# Variables

#archive="https://ftp.mozilla.org/pub/security/nss/releases/NSS_`echo "$version" | tr . _`_RTM/src/nss-$version-with-nspr-$v_nspr.tar.gz"
archive="https://ftp.mozilla.org/pub/security/nss/releases/NSS_`echo "$version" | tr . _`_RTM/src/nss-$version.tar.gz"
dest="$INSTALLS/$logiciel-$version"

[ -d "$dest" ] && exit 0

prerequis

obtenirEtAllerDansVersion
cd nss

echo Correction… >&2
for modif in true $modifs ; do $modif ; done

echo Configuration… >&2
configure --prefix="$dest" $OPTIONS_CONF

echo Compilation… >&2
#CC=cc CCC=c++ BUILD_OPT=1 USE_64=1 make nss_build_all # Si l'on embarque nspr avec.
CC=cc CCC=c++ BUILD_OPT=1 USE_64=1 make

echo Installation… >&2
install

# On n'utilise pas, car NSS est un sacré bazar et installerait donc plein de machins en conflit avec les biblios "système".
#sutiliser "$logiciel-$version"
( cd "$INSTALLS/lib" ; destrel="../`basename "$dest"`/lib" ; sudo ln -s "$destrel/libssl3.so" "$destrel/libsmime3.so" "$destrel/libnss3.so" "$destrel/libnssutil3.so" ./ )

rm -Rf "$TMP/$$"
