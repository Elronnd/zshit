#!/bin/zsh
#!useage: lambda addtwo=a b . $((a + b))
#!But you can also have something like this for anonymous (although why would you do that)
#!lambda -=a b . $((a + b)) . 1 9
#!to make an anon lambda and call it right away
#!TODO (because ^^ doesn't work yet)
#!But maybe it shouldn't?
##\
###\
####\___________________________________________________________________________________________
################################################################################################|
##### #### ### ## #  #   #    #     #      EX/AMPL\ES      #     #    #   #  # ## ### #### #####|
################################################################################################|
##                                                                                 #############|
#  lambda contains=haystack needle . grep -E $needle '<<< $haystack &> /dev/null' ##############|
#  lambda addtwo=a b . '(a+b)'                                                   ###############|
##                                                                              ################|
################################################################################################|
################################################################################################|
##                                                                                      ########|
#  lambda addall= . '[[ $# = 2 ]] && echo $(($1+$2)) || echo $(($1+$(addall ${@:2})))'   #######|
##                                                                                        ######|
#  Or to make loli happy because he wants everything to be functional:                     #####|
#  lambda addall= . '[[ $# = 2 ]] && return $(($1+$2)) || return $(($1+$(addall ${@:2})))'  ####|
##                                                                                           ###|
################################################################################################|
####---------------------------------------------------------------------------------------------
###/
##/
#"



lambda() {
	local fname
	local args
	local functioneval=""
	local namedargs=()
	local progstarts=2 # the index in args when the program starts.  It must be at least 2, because 1 would be the terminating .
	# yes, zsh has 1-indexed arrays

	if (grep -E "=.+" <<< $1 &> /dev/null); then # is there something after the +?
		namedargs=(${1//*=/}) # get rid of everything before the =, so we get only the variable which is after
	fi

	fname=${1//=*/} # get rid of everything after the =

	args=$@[2,-1]

	for i in ${(s: :)args}; do
		if [[ $i = '.' ]]; then break; fi

		namedargs=($namedargs $i)
		progstarts=$((progstarts+1))
	done

	prog=$@[$((progstarts+1)),-1]

	functioneval="$fname() {"
	local argcounter=1
	for i in $namedargs; do
		functioneval="$functioneval
		local $i=\$$argcounter
"
		argcounter=$((argcounter+1))
	done
	functioneval="$functioneval
	ret=\$($prog)
	retv=\$?
	print -R -n \$ret
	return \$retv
	}"

	eval $functioneval


	# if only zsh had closures...
	# $fname() {
	# 	local counter=1
	# 	for i in $namedargs; do
	# 		: local ${(P)i=${(P)counter}}
	# 		counter=$((counter+1))
	# 	done
	#
	# 	print -R -n $prog
	# }
}
