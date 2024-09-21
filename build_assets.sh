#!/usr/bin/env sh

# Define a function to compare file modification times and execute a command if conditions are met
# Arguments:
#   1: Source file
#   2: Destination file
#   3: Time difference in seconds
#   4: Command to execute if the source file is newer by the specified interval
check_and_execute() {
  local src_file="$1"
  local dest_file="$2"
  local time_diff_threshold="$3"
  local command="$4"

  # Get modification times, default to 0 if file does not exist
  local src_mod_time=$(stat -c %Y "$src_file" 2>/dev/null || echo 0)
  local dest_mod_time=$(stat -c %Y "$dest_file" 2>/dev/null || echo 0)

  # Calculate time difference
  local time_diff=$((src_mod_time - dest_mod_time))

  # Execute command if source file is newer by the specified threshold
  if [ "$time_diff" -gt "$time_diff_threshold" ]; then
    echo "Executing command for: $src_file"
    eval "$command"
  else
    echo "Skipping: $src_file (not modified significantly)"
  fi
}


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
timeout=7

# Define file paths 
src_pu_files="$DIR/src/assets/*.pu"
dest_svg_dir="$DIR/assets/"


# Assuming we want to compare each .pu file individually (loop required)
for src_file in $src_pu_files; do
  base_name=$(basename "$src_file" .pu)
  dest_file="$dest_svg_dir${base_name}.svg"

  plantuml_command="CLASSPATH=$CLASSPATH:/usr/share/java/jlatexmath-minimal-1.0.3.jar:/usr/share/java/batik-all-1.7.jar:/usr/share/java/jlm_cyrillic.jar:/usr/share/java/jlm_greek.jar plantuml -tsvg -o '$dest_svg_dir' '$src_file'"
 

  check_and_execute "$src_file" "$dest_file" "$timeout" "$plantuml_command"
done

# For the Julia script, assuming a single output file for simplicity
julia_command="julia --project='$DIR' '$DIR/src/assets/Soundness.jl'"
julia_src_file="$DIR/src/assets/Soundness.jl"
julia_dest_file="$DIR/assets/soundness.svg"
check_and_execute "$julia_src_file" "$julia_dest_file" "$timeout" "$julia_command"
