#!/bin/bash

#Local Variables
DOWNLOAD_URL="https://umod.org/games/rust/download"
TEMP_FOLDER="/temp"
DOWNLOAD_DESTINATION="/tmp/rust_update.zip"
ROOT_DIRECTORY="/"
LOCAL_VERSION_FILE="/local_oxide_version.txt"
REPO_URL="https://github.com/umod-community/umod-rust"
FILENAME="Oxide.Rust.zip"

# Check if Rust is installed
check_rust_installed() {
    if ! command -v rustserver > /dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

# Download Rust server from Steam
download_rust_server() {
    echo "Rust server not installed. Downloading from Steam..."
    ./steamcmd.sh +login anonymous +app_update 258550 validate +quit
}

# Check if Oxide is installed
check_umod_installed() {
    if [ ! -d "umod_dir" ]; then
        return 1
    else
        return 0
    fi
}

# Update/install Rust and UMod
update_install_rust_umod() {
    echo "Updating/Installing Rust..."
    download_rust_server
    # Download and unzip Oxide Rust then clean up temp folder
    echo "Updating/Installing UMod..."
    mkdir -p "$TEMP_FOLDER"
    echo "Downloading update..."
    latest_version=$(curl -LIs "${REPO_URL}/releases/latest" | grep -i '^location:' | cut -d' ' -f2 | cut -d'/' -f8)
    local_version=$(<"$LOCAL_VERSION_FILE")

    if [ "$latest_version" != "$local_version" ]; then
        if curl -Ls "${REPO_URL}/releases/download/${latest_version}/${FILENAME}" -o "${DOWNLOAD_DESTINATION}"; then
            echo "Downloaded ${FILENAME} Successfully."
            echo "$latest_version" > "$LOCAL_VERSION_FILE"
            echo "Unzipping update..."
            unzip -o "$DOWNLOAD_DESTINATION" -d "$ROOT_DIRECTORY"
        else
            echo "Failed to download UMod update."
        fi
    else
        echo "No updates available for UMod."
    fi
    
    echo "Cleaning up..."
    rm -rf "$TEMP_FOLDER"
    echo "Update completed successfully!"
}

# Start the server with the convars
start_server() {
    echo "Starting server..."
    ./RustDedicated -batchmode 
	{{SERVER_MEMORY}} 
	{{SERVER_IP}} 
	{{SERVER_PORT}} 
	{{HOSTNAME}} 
	{{LEVEL}} 
	{{DESCRIPTION}} 
	{{SERVER_URL}} 
	{{WORLD_SIZE}} 
	{{WORLD_SEED}} 
	{{MAX_PLAYERS}} 
	{{SERVER_IMG}}
	{{RCON_PORT}}
	{{RCON_PASS}}
	{{ADDITIONAL_ARGS}}
    {{SAVEINTERVAL}}
    {{APP_PORT}}
    {{SERVER_LOGO}}
    {{MAP_URL}}
    {{QUERY_PORT}}
    {{FRAMEWORK}}
}

if ! check_rust_installed; then
    download_rust_server
fi

if ! check_umod_installed; then
    update_install_rust_umod
else
    echo "UMod already installed. Checking for updates..."
    update_install_rust_umod
fi

start_server
