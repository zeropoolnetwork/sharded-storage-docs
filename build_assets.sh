#!/usr/bin/env sh

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

plantuml -tsvg -o "$DIR/assets/" "$DIR/src/assets/*.pu"
julia --project="." src/assets/Soundness.jl
