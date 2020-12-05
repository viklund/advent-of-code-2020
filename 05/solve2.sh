#!/usr/bin/env bash

perl solve1.pl input | sort -n | perl -lnE 'BEGIN{($$l) = (90)}; if ($l+2 == $_){say $l+1}$l=$_'
