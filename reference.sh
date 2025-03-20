#!/usr/bin/env bash

 _date() { date +%H:%M:%S; }
_trace() { echo -e "[$(_date)] [\e[35mTRACE\e[0m]" "$@"; }
_debug() { echo -e "[$(_date)] [\e[34mDEBUG\e[0m]" "$@"; }
 _info() { echo -e "[$(_date)] [\e[32mINFO\e[0m]" "$@"; }
 _warn() { echo -e "[$(_date)] [\e[33mWARN\e[0m]" "$@"; }
_error() { echo -e "[$(_date)] [\e[31mERROR\e[0m]" "$@"; }
 trace() { _trace "$@"; "$@"; }

_flwr_deny=()
_flwr_allow=()
trace mkdir -p /tmp/_flwr/pool

{ while read -r path; do _debug "$path"; if [[ "$path" == \!* ]]; then _flwr_deny+=("${path#*\!}"); else _flwr_allow+=("$path"); fi; done }<<<"$paths"

_debug _flwr_deny -\> "${_flwr_deny[@]}"
_debug _flwr_allow -\> "${_flwr_allow[@]}"

succeeded=1

for v in "${_flwr_allow[@]}"; do
	_info "Iterating over $v"
	for i in $v; do
		for c in "${_flwr_deny[@]}"; do
			if [[ "$i" == $c ]]; then
				_trace "Skipping $i as it conforms to $c"
				continue 2;
			fi
		done
		if trace mv -v "$i" /tmp/_flwr/pool/; then
			succeeded=0
		else
			_warn "Could not move $i, mv returned: $?"
		fi
	done
done

if [ $succeeded -ne 0 ]; then
	_error "Did not find files to move."
fi

exit $succeeded