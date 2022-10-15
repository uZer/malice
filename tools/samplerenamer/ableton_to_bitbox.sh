#!/bin/bash

set -euo pipefail

################################################################################

projectName=$(basename "$(pwd)")
midiNoteOffset=0
midiNoteVelocity=100

################################################################################

usage () {
  cat << EOF
Convert filenames. Will ask for a confirmation.

USAGE: $0
EOF
}

convertRootNote () {
  note="${1:0:1}"
  case $note in
    C) echo 0;;
    D) echo 2;;
    E) echo 4;;
    F) echo 5;;
    G) echo 7;;
    A) echo 9;;
    B) echo 11;;
    *) echo "Error parsing note." && exit 2
  esac
}

convertOffset () {
  note="${1:1:3}"
  sharp=0
  [[ "${note:0:1}" == "#" ]] && sharp=1 && note=${note:1:2}
  echo "( ${note} * 12 ) + ${sharp} + ${midiNoteOffset}" | bc
}

convertAbletonToBitbox () {
  project="${1}"
  filename="${2}"
  note="${filename%%[[:space:]]*}"
  midinote=$(printf '%03i' "$(echo "$(convertRootNote "${note}") + $(convertOffset "${note}")" | bc)")
  echo "${project}-${midinote}-${midiNoteVelocity}.wav"
}

################################################################################

[[ ! $# -eq 0 ]] && usage && exit 1

IFS=$'\n'

for filename in *.wav; do
  echo "mv \"${filename}\" \"$(convertAbletonToBitbox "${projectName}" "${filename}")\""
done

read -p "Is this correct? [y/N]" -n 1 -r
echo
if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
  echo "Quitting."
  exit 0
fi

for filename in *.wav; do
  mv "${filename}" "$(convertAbletonToBitbox "${projectName}" "${filename}")"
done
