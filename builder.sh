#!/usr/bin/env bash
# -------------------------------------------------------------
# HyperX <MODULE> Installer Template
# -------------------------------------------------------------
# Author: Faroncoder
# Version: 1.0.0
# -------------------------------------------------------------
# Usage:
#   git clone https://github.com/<you>/hyperx_<module>.git \
#     && cd hyperx_<module> && bash install_hyperx_<module>.sh
# -------------------------------------------------------------

set -e
# DECLAREGLOBALS

HYPERX_DIR="$HOME/.hyperx"
HYPERX_BIN="$HYPERX_DIR/bin"
HYPERX_INSTALL="$HYPERX_DIR/installs"
HYPERX_MOD="$HYPERX_DIR/modules"
HYPERX_MOD_DIR="$HYPERX_MOD/$TYPE"
LOADER="$HYPERX_DIR/hyperx_init.sh"
# DECLAREGLOBALSEND


echo "-------------------------------------------------------------"
echo "🔧  HyperX ${TYPE^} Installer"
echo "-------------------------------------------------------------"

# -------------------------------------------------------------
# Step 1: Create universal loader if missing
# -------------------------------------------------------------
if [[ ! -f "$LOADER" ]]; then
  echo "🧩 Creating universal HyperX loader..."
  if [[ ! -d "$HYPERX_DIR" ]]; then
	echo "📁 Creating HyperX directory at $HYPERX_DIR"
	mkdir -p "$HYPERX_DIR"
	mkdir -p "$HYPERX_BIN"
	mkdir -p "$HYPERX_INSTALL"
	mkdir -p "$HYPERX_MOD"
  fi
  
cat > "$LOADER" <<'EOF'
#!/usr/bin/env bash
# -------------------------------------------------------------
# HyperX Universal Loader (bash + zsh)
# -------------------------------------------------------------
HYPERX_DIR="$HOME/.hyperx"
HYPERX_BIN="$HYPERX_DIR/bin"
HYPERX_INSTALL="$HYPERX_DIR/installs"
HYPERX_MOD="$HYPERX_DIR/modules"


export PATH="$HYPERX_BIN:$PATH"
# Load global functions

source "$HYPERX_BIN/hx_functions" 2>/dev/null || true

# Load all module scripts
find "$HYPERX_MOD" -type f -name "hx_*" -exec bash -c '[[ -r "$0" ]] && source "$0" >/dev/null 2>&1' {} \;

hx_check

echo "✨ HyperX environment initialized"



EOF

chmod 644 "$LOADER"
chmod +x "$LOADER"

  cat > "$HYPERX_BIN/hx_functions" <<'EOF'
#!/bin/bash


# function to install module 
function hx_get_module_name () {
	unset filename TYPE module_name file_install_path module_file module_dir module_path
	 file="${HYPERX_INSTALL}/$1"
	 filename="$( basename "$file" )"
	 TYPE="$( echo $filename | cut -d '_' -f4 )"
	 module_name="${TYPE}"
	 file_install_path="$HYPERX_INSTALL/_install_hx_${module_name}"
	 module_file="hx_${module_name}"
	 module_dir="$HYPERX_MOD/$module_name"
	 module_path="$module_dir/$module_file"

	if [[ "$file" == "$file_install_path" ]]; then
		echoresult 0 "Module install path confirmed for $module_name"
	fi
}


hx_process_install() {
	GETAPP=( $( ls "$HYPERX_INSTALL" 2>/dev/null ) )
	if [[ ! -z "$GETAPP" ]]; then
	  echo "📦 Processing pending module installations..."

		for f in "${GETAPP[@]}"; do
			hx_get_module_name "$f"
			mkdir -p "$module_dir"
			mv "${file_install_path}" "${module_path}"
			chmod +x "$module_path"
			echo "✅ Module '${module_name}' installed."
		done
	fi
}

function hx_check() {
	CHECK=$( find "$HYPERX_INSTALL" -type f )
	if [[ ! -z "$CHECK" ]]; then
	  hx_process_install
	else
	  echo "✅ No pending module installations found"
	fi
}


hx_module_grab() {
  module_name="$1"
  base_repo="https://github.com/faroncoder"
  module_repo="hyperx_${module_name}"
  target_dir="$HYPERX_INSTALL"

  if [[ -z "$module_name" ]]; then
    echo "Usage: hx_module_grab <module>"
    echo "Example: hx_module_grab postgresql"
    return 1
  fi

  echo "📦 Fetching module '${module_name}'..."
  git clone "${base_repo}/${module_repo}.git" "$HYPERX_INSTALL" && source ~/.hyperx/hyperx_init.sh
}


hx_menu() {
  echo "🧭 HyperX Command Menu"
  echo "---------------------------------------------"
  echo "Scanning loaded modules..."
  echo

  # Find all fx.* functions across all sourced modules
  local fx_funcs
  fx_funcs=$(declare -F | awk '{print $3}' | grep '^fx\.' | sort)

  if [[ -z "$fx_funcs" ]]; then
    echo "⚠️  No HyperX functions detected. Try 'source ~/.hyperx/hyperx_init.sh'"
    return 0
  fi

  local count=1
  while read -r f; do
    printf "%2d) %s\n" "$count" "$f"
    ((count++))
  done <<< "$fx_funcs"

  echo "---------------------------------------------"
  echo "Total: $((count - 1)) functions loaded."
  echo
  echo "✨ Tip: run 'type <function>' to inspect a command."
}


EOF

chmod 644 "$HYPERX_BIN/hx_functions"
chmod +x "$HYPERX_BIN/hx_functions"





# -------------------------------------------------------------
# Step 2: Link loader to rc files
# -------------------------------------------------------------
if [[ -f "$HOME/.bashrc" ]] ;  then
  if ! grep -Fq "hyperx_init.sh" "$HOME/.bashrc" ; then
  	echo "# Load HyperX Framework" >> "$HOME/.bashrc"
	echo "source ~/.hyperx/hyperx_init.sh" >> "$HOME/.bashrc"
	echo "✅  Added loader reference to ~/.bashrc"
	source "$HOME/.bashrc" 2>/dev/null || true
	echo "Hyperx ready to go!"
  fi
fi

if [[ -f "$HOME/.zshrc" ]] ;  then
  if ! grep -Fq "hyperx_init.sh" "$HOME/.zshrc" ; then
  	echo "# Load HyperX Framework" >> "$HOME/.zshrc"
	echo "source ~/.hyperx/hyperx_init.sh" >> "$HOME/.zshrc"
	echo "✅  Added loader reference to ~/.zshrc"
	source "$HOME/.zshrc" 2>/dev/null || true
	echo "Hyperx ready to go!"
  fi
fi


fi

echo "Hyperx System Installation Complete"

rm "$0"
