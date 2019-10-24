# Copyright (c) 2019 Guillaume Outters
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

prerequisOpenssl()
{
	local osslxx=ossl11
	
	if option ossl10
	then
		osslxx=ossl10
		prerequis="`echo " $prerequis " | sed -e 's# openssl # openssl >= 1.0 < 1.1 #'`"
	elif option ossl11
	then
		osslxx=ossl11
		prerequis="`echo " $prerequis " | sed -e 's# openssl # openssl >= 1.1 < 1.2 #'`"
	else
		local filtre="`decoupePrerequis "$prerequis" | grep '^openssl[+ ]'`"
		[ -n "$filtre" ] || filtre="openssl"
		local vlocal="`versions "$filtre" | tail -1 | sed -e 's/.*-//'`"
		local vmajlocal="`echo "$vlocal" | sed -e 's/\.//' -e 's/\..*//'`"
		if [ ! -z "$vmajlocal" ]
		then
			argOptions="`options "$argOptions+ossl$vmajlocal" | tr -d ' '`"
			osslxx=ossl$vmajlocal
			prerequis="`echo " $prerequis " | sed -e "s# openssl # openssl $vlocal #"`"
		fi
	fi
	argOptions="`options "$argOptions-openssl-ossl"`" # Les +openssl ou +ossl disparaissent au profit du +ossl1x.
	prerequis="`echo " $prerequis " | sed -e "s#+osslxx#+$osslxx#"`"
}
