# Copyright (c) 2003-2005,2008,2011-2019 Guillaume Outters
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

# Renvoie les versions pour un logiciel donnée, triées par version croissante.
versions()
{
	local GUILI_PATH="$GUILI_PATH"
	[ ! -z "$GUILI_PATH" ] || GUILI_PATH="$INSTALLS"
	
	versions_expr_version='[0-9.]+'
	[ "x$1" = x-v ] && versions_expr_version="$2" && shift && shift || true
	versions_logiciel="`echo "$1" | cut -d + -f 1`"
	local options="`echo "$1" | cut -s -d + -f 2-`" # Le -s est super important!
	options="`options "+$options" | sed -e 's/[-=+][-=+]*\([-=+]\)/\1/g' -e 's/[-=+]$//'`"
	local versions_expr= versions_expr_excl=
	case "$options" in
		*+*) versions_expr="/$versions_logiciel`argOptions="$options" argOptions | sed -e 's/-[^-=+]*//g' -e 's#[+]#([+][^+]*)*[+]#g'`([+][^+]*)*-$versions_expr_version$" ;;
	esac
	case "$options" in
		*-*) versions_expr_excl="/$versions_logiciel([+][^+]*)*`echo "$options" | sed -e 's/[+][^-=+]*//g' -e 's#-#|[+]#g' -e 's#|#(#'`)([+][^+]*)*-$versions_expr_version$" ;;
	esac
	(
		IFS=:
		find $GUILI_PATH -maxdepth 1 \( -name "$versions_logiciel-*" -o -name "$versions_logiciel+*-*" \)
	) | egrep "$versions_expr" | ( [ -z "$versions_expr_excl" ] && cat || egrep -v "$versions_expr_excl" ) | filtrerVersions "$2" | triversions
}
