# Copyright (c) 2012,2015,2017-2018 Guillaume Outters
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

# Teste si la version mentionnée en premier paramètre rentre (ou est plus petite ou égale, si le second paramètre vaut 'ppe') dans l'intervalle défini par la suite des arguments (ex.: testerVersion 2.3.1 >= 2.3 < 2.4 renverra vrai).
testerVersion()
{
	[ "x$1" = x ] && return 0 # Sans mention de version, on dit que tout passe.
	versionTestee="$1"
	shift
	plusPetitOuEgal=false
	[ "x$1" = xppe ] && plusPetitOuEgal=true && shift
	while [ $# -gt 0 ]
	do
		case "$1" in
			">=")
				$plusPetitOuEgal || pge "$versionTestee" "$2" || return 1 # Si on teste un PPE, le >= n'est pas filtrant (la clause PPE est prioritaire).
				shift
				;;
			">")
				$plusPetitOuEgal || pg "$versionTestee" "$2" || return 1
				shift
				;;
			"<")
				pg "$2" "$versionTestee" || return 1
				shift
				;;
			*) # Numéro de version précis.
				if $plusPetitOuEgal
				then
					pge "$1" "$versionTestee" || return 1
				else
					[ "$versionTestee" = "$1" ] || vc "$1" "$versionTestee" || return 1
				fi
				;;
		esac
		shift
	done
	true
}

pge() { pg -e "$1" "$2" ; }

# Compare deux versions.
# Utilisation: vc [--var <var>|-v <var>|-e] <version0> <version1>
#   (sans mode)
#     Renvoie 255, 0, ou 1, selon que <version0> <, =, ou >, à <version1>.
#   --var|-v
#     Affecte -1, 0, ou 1, à $var.
#   -e
#     Fait un echo de -1, 0, ou 1.
vc()
{
	local _vc_r _vc_re _vc_mode=r _vc_var
	
	[ "x$1" = x--var -o "x$1" = x-v ] && _vc_mode=v && _vc_var="$2" && shift && shift || true
	[ "x$1" = x-e ] && _vc_mode=e && shift || true
	
	IFS=.
	_vc "$1" $2 || _vc_r="$?"
	unset IFS
	
	case $_vc_r in
		255) _vc_re=-1 ;;
		*) _vc_re=$_vc_r ;;
	esac
	
	case $_vc_mode in
		v) eval $_vc_var=$_vc_re ;;
		e) printf "%d" $_vc_re ;;
		*) return $_vc_r
	esac
}

_vc()
{
	local a b as="$1" ; shift
	for a in $as
	do
		b="$1"
		[ -n "$b" ] || b=0
		[ "$a" -ge "$b" ] || return 255
		[ "$a" -eq "$b" ] || return 1
		[ $# -le 0 ] || shift
	done
	while [ $# -gt 0 ]
	do
		[ "$1" -le 0 ] || return 255
		[ "$1" -eq 0 ] || return 1
		shift
	done
}

triversions()
{
	# De deux logiciels en même version, on prend le chemin le plus long: c'est celui qui embarque le plus de modules optionnels.
	awk '
		BEGIN {
			# Certaines versions d awk veulent que ls soit initialisée en array avant de pouvoir être length()ée.
			nls = 0;
			nvs = 0;
			ntailles = 0;
		}
		{
			ls[++nls] = $0;
			v = $0;
			sub(/^([^0-9][^-]*-)+/, "", v);
			vs[++nvs] = v;
			ndecoupe = split(v, decoupe, ".");
			for(i = 0; ++i <= ndecoupe;)
			{
				if(i > ntailles)
				{
					++ntailles;
					tailles[i] = 0;
				}
				if(length(decoupe[i]) > tailles[i])
					tailles[i] = length(decoupe[i]);
			}
		}
		END {
			for(nl = 0; ++nl <= nvs;)
			{
				c = "";
				v = vs[nl];
				ndecoupe = split(v, decoupe, ".");
				for(nv = 0; ++nv <= ntailles;)
					c = c sprintf("%0"tailles[nv]"d", nv > ndecoupe ? 0 : decoupe[nv]);
				print c" "sprintf("%04d", length(ls[nl]))" "ls[nl]
			}
		}
	' | sort | cut -d ' ' -f 3-
}

filtrerVersions()
{
	sed -e '/^.*-\([0-9.]*\)$/!d' -e 's##\1 &#' | while read v chemin
	do
		if testerVersion "$v" $@
		then
			echo "$chemin"
		fi
	done
}
