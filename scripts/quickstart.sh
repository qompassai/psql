#!/usr/bin/env bash
# /qompassai/psql/scripts/quickstart.sh
# Qompass AI PostgreSQL (Cross-Platform) Quick Start
# Copyright (C) 2025 Qompass AI
####################################################
set -euo pipefail
detect_os() {
	unameOut="$(uname -s)"
	case "${unameOut}" in
	Linux*) OS="linux" ;;
	Darwin*) OS="macos" ;;
	CYGWIN* | MINGW* | MSYS* | Windows*) OS="windows" ;;
	*) OS="unknown" ;;
	esac
}
detect_linux_distro() {
	if [ -f /etc/os-release ]; then
		. /etc/os-release
		DISTRO_ID=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
		DISTRO_LIKE=$(echo "${ID_LIKE:-}" | tr '[:upper:]' '[:lower:]')
	else
		DISTRO_ID="unknown"
		DISTRO_LIKE=""
	fi
}
is_postgres_installed() {
	if command -v psql &>/dev/null; then
		echo "✅ PostgreSQL is already installed: $(psql --version)"
		return 0
	fi
	return 1
}
install_postgresql_linux() {
	echo "==> Installing PostgreSQL for distribution: $DISTRO_ID"
	case "$DISTRO_ID" in
	debian | ubuntu | linuxmint | pop)
		sudo apt-get update
		sudo apt-get install -y postgresql postgresql-contrib
		;;
	fedora | rhel | centos)
		sudo dnf install -y postgresql-server postgresql-contrib
		sudo postgresql-setup --initdb --unit postgresql
		sudo systemctl enable postgresql
		sudo systemctl start postgresql
		;;
	arch | manjaro)
		sudo pacman -Sy --noconfirm postgresql
		sudo -iu postgres initdb --locale en_US.UTF-8 -D '/var/lib/postgres/data'
		sudo systemctl enable postgresql
		sudo systemctl start postgresql
		;;
	nixos)
		echo "❗ On NixOS, use configuration.nix or $(nix-shell) to manage system services."
		echo "For example:"
		echo '  services.postgresql.enable = true;'
		echo "Or:"
		echo "  nix-shell -p postgresql"
		;;
	*)
		if [[ "$DISTRO_LIKE" == *"debian"* ]]; then
			sudo apt-get update
			sudo apt-get install -y postgresql postgresql-contrib
		elif [[ "$DISTRO_LIKE" == *"fedora"* ]] || [[ "$DISTRO_LIKE" == *"rhel"* ]]; then
			sudo dnf install -y postgresql-server postgresql-contrib
			sudo postgresql-setup --initdb --unit postgresql
			sudo systemctl enable postgresql
			sudo systemctl start postgresql
		else
			echo "❌ Unsupported Linux distribution. Please install PostgreSQL manually."
			exit 1
		fi
		;;
	esac
}
install_postgresql_macos() {
	echo "==> Installing PostgreSQL on macOS..."
	if ! command -v brew &>/dev/null; then
		echo "Homebrew not found. Installing Homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	brew update
	brew install postgresql
	brew services start postgresql
}
install_postgresql_windows() {
	if grep -qi microsoft /proc/version 2>/dev/null; then
		DISTRO_ID="debian"
		install_postgresql_linux
		return
	fi
	echo "ℹ️ Native Windows install is not automated."
	echo "Please use the official PostgreSQL installer:"
	echo "https://www.postgresql.org/download/windows/"
	echo
	echo "After installation, reopen your terminal and run:"
	echo "  psql -U postgres"
	exit 0
}
setup_postgres_user() {
	echo "==> Setting up 'postgres' user (if necessary)..."
	if sudo -u postgres psql -c '\q' 2>/dev/null; then
		echo "✅ PostgreSQL is initialized."
	else
		echo "⚠ Creating default 'postgres' user and DB..."
		sudo -u postgres createuser -s postgres || true
		sudo -u postgres createdb postgres || true
	fi

	echo
	echo "🎯 You can now connect to PostgreSQL with:"
	echo "    sudo -u postgres psql"
}
main() {
	detect_os
	echo "🔍 Detected OS: $OS"
	if is_postgres_installed; then
		echo "ℹ️ Skipping install since PostgreSQL is already available."
		exit 0
	fi
	if [ "$OS" = "linux" ]; then
		detect_linux_distro
		install_postgresql_linux
		setup_postgres_user
	elif [ "$OS" = "macos" ]; then
		install_postgresql_macos
	elif [ "$OS" = "windows" ]; then
		install_postgresql_windows
	else
		echo "❌ Unsupported or unknown system: $OS"
		exit 1
	fi
	echo
	echo "🍀 PostgreSQL installation complete!"
}
main "$@"
