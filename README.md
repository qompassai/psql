<!-- /qompassai/psql/README.md -->
<!-- ---------------------------- -->
<!-- Copyright (C) 2025 Qompass AI, All rights reserved -->

<h3> PostgreSQL </h3>

<h2> Qompass AI on PostGres </h2>

![Repository Views](https://komarev.com/ghpvc/?username=qompassai-psql)
![GitHub all releases](https://img.shields.io/github/downloads/qompassai/psql/total?style=flat-square)
<a href="https://www.postgresql.org/">
	<img src="https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white"
		alt="PostgreSQL">
</a>
<br>
<a href="https://www.postgresql.org/docs/">
	<img src="https://img.shields.io/badge/PostgreSQL_Documentation-blue?style=flat-square"
		alt="PostgreSQL Documentation">
</a>
<a href="https://github.com/topics/postgresql-tutorial">
	<img src="https://img.shields.io/badge/PostgreSQL_Tutorials-green?style=flat-square" alt="PostgreSQL Tutorials">
</a>
<br>
<a href="./LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" alt="License: Apache 2.0"></a>

</p>


<details>
	<summary
		style="font-size: 1.4em; font-weight: bold; padding: 15px; background: #667eea; color: white; border-radius: 10px; cursor: pointer; margin: 10px 0;">
		<strong>▶️ Qompass AI Quick Start</strong>
	</summary>
	<div style="background: #f8f9fa; padding: 15px; border-radius: 5px; margin-top: 10px; font-family: monospace;">

		```bash
		bash <(curl -L https://raw.githubusercontent.com/qompassai/psql/main/scripts/quickstart.sh) ``` </div>
			<blockquote
				style="font-size: 1.2em; line-height: 1.8; padding: 25px; background: #f8f9fa; border-left: 6px solid #667eea; border-radius: 8px; margin: 15px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
				<details>
					<summary
						style="font-size: 1em; font-weight: bold; padding: 10px; background: #e9ecef; color: #333; border-radius: 5px; cursor: pointer; margin: 10px 0;">
						<strong>📄 We advise you read the script BEFORE running it 😉</strong>
					</summary>
					<pre
						style="background: #fff; padding: 15px; border-radius: 5px; border: 1px solid #ddd; overflow-x: auto;">

						#!/usr/bin/env bash
						# /qompassai/psql/scripts/quickstart.sh
						# Qompass AI PostgreSQL (Cross-Platform) Quick Start
						# Copyright (C) 2025 Qompass AI
						####################################################

						set -euo pipefail

						PORT=5432
						DATA_DIR="$HOME/.local/share/qompass/harbor"
						PG_LOG="$HOME/.local/share/qompass/pg.log"
						DB_NAME="qompass"
						DBX_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/nvim/dbx.lua"
						DB_ENTRY_NAME="Qompass AI Harbor"

						mkdir -p "$(dirname "$DBX_FILE")"
						mkdir -p "$HOME/.local/share/qompass"

						detect_os() {
						case "$(uname -s)" in
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
						if command -v psql >/dev/null; then
						echo "✅ PostgreSQL is already installed: $(psql --version)"
						return 0
						fi
						return 1
						}

						install_postgresql_linux() {
						echo "==> Installing PostgreSQL for: $DISTRO_ID"
						case "$DISTRO_ID" in
						debian | ubuntu | linuxmint | pop)
						sudo apt update
						sudo apt install -y postgresql postgresql-contrib
						;;
						arch | manjaro)
						sudo pacman -Sy --noconfirm postgresql
						;;
						fedora | rhel | centos)
						sudo dnf install -y postgresql-server postgresql-contrib
						;;
						nixos)
						echo "❗ On NixOS, use configuration.nix or nix-shell to enable PostgreSQL."
						;;
						*)
						echo "❌ Unsupported Linux distro. Please install PostgreSQL manually."
						exit 1
						;;
						esac
						}

						install_postgresql_macos() {
						echo "==> Installing PostgreSQL on macOS..."
						if ! command -v brew >/dev/null; then
						echo "Installing Homebrew..."
						/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
						fi
						brew install postgresql
						brew services start postgresql
						}

						install_postgresql_windows() {
						echo "ℹ️ Native Windows install is not automated."
						echo "Get the installer from: https://www.postgresql.org/download/windows/"
						exit 1
						}

						setup_user_cluster() {
						if [ ! -d "$DATA_DIR/base" ]; then
						echo "==> Initializing user-local PostgreSQL cluster in $DATA_DIR"
						initdb -D "$DATA_DIR"
						fi

						if ! pg_ctl -D "$DATA_DIR" -l "$PG_LOG" status >/dev/null 2>&1; then
						echo "==> Starting PostgreSQL server..."
						pg_ctl -D "$DATA_DIR" -l "$PG_LOG" start
						sleep 2
						else
						echo "ℹ️ PostgreSQL server already running."
						fi

						if ! psql -h localhost -p "$PORT" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
						echo "✅ Creating database: $DB_NAME"
						createdb -h localhost -p "$PORT" "$DB_NAME"
						else
						echo "ℹ️ Database '$DB_NAME' already exists."
						fi
						}

						write_dbx_file() {
						echo "==> Writing database entry to: $DBX_FILE"

						cat >"$DBX_FILE" <<EOF -- Qompass AI Diver Database Config -- Auto-generated by quickstart.sh
							return { { name="${DB_ENTRY_NAME}" , url="postgresql://$USER@localhost:${PORT}/${DB_NAME}" }
							} EOF echo "✅ DBX file updated: $DBX_FILE" } main() { detect_os echo "🔍 OS detected: $OS"
							if ! is_postgres_installed; then echo "==> PostgreSQL not detected, installing..." if
							[ "$OS"="linux" ]; then detect_linux_distro install_postgresql_linux elif [ "$OS"="macos" ];
							then install_postgresql_macos elif [ "$OS"="windows" ]; then install_postgresql_windows else
							echo "❌ Unsupported OS: $OS" exit 1 fi fi setup_user_cluster write_dbx_file echo
							echo "🚀 Your local PostgreSQL instance is ready." echo "📡 Connection URL:"
							echo "   postgresql://$USER@localhost:$PORT/$DB_NAME" echo
							echo "🧠 Use this in Neovim DBUI or CLI:"
							echo "   psql -h localhost -p $PORT -U $USER -d $DB_NAME" } main "$@" </pre>
				</details>
				<p>Or, <a href="https://github.com/qompassai/psql/blob/main/scripts/quickstart.sh" target="_blank">View
						the quickstart script</a>.</p>
			</blockquote>
</details>

</blockquote>
</details>

<details>
	<summary
		style="font-size: 1.4em; font-weight: bold; padding: 15px; background: #667eea; color: white; border-radius: 10px; cursor: pointer; margin: 10px 0;">
		<strong>🧭 About Qompass AI</strong>
	</summary>
	<blockquote
		style="font-size: 1.2em; line-height: 1.8; padding: 25px; background: #f8f9fa; border-left: 6px solid #667eea; border-radius: 8px; margin: 15px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">

		<div align="center">
			<p>Owner<br>
				Former Intelligence Officer<br>
				Educator & Learner<br>
				DeepTech Founder & CEO</p>
		</div>

		<h3>Publications</h3>
		<p>
			<a href="https://orcid.org/0000-0002-0302-4812">
				<img src="https://img.shields.io/badge/ORCID-0000--0002--0302--4812-green?style=flat-square&logo=orcid"
					alt="ORCID">
			</a>
			<a href="https://www.researchgate.net/profile/Matt-Porter-7">
				<img src="https://img.shields.io/badge/ResearchGate-Open--Research-blue?style=flat-square&logo=researchgate"
					alt="ResearchGate">
			</a>
			<a href="https://zenodo.org/communities/qompassai">
				<img src="https://img.shields.io/badge/Zenodo-Publications-blue?style=flat-square&logo=zenodo"
					alt="Zenodo">
			</a>
		</p>

		<h3>Developer Programs</h3>

		[![NVIDIA
		Developer](https://img.shields.io/badge/NVIDIA-Developer_Program-76B900?style=for-the-badge\&logo=nvidia\&logoColor=white)](https://developer.nvidia.com/)
		[![Meta
		Developer](https://img.shields.io/badge/Meta-Developer_Program-0668E1?style=for-the-badge\&logo=meta\&logoColor=white)](https://developers.facebook.com/)
		[![HackerOne](https://img.shields.io/badge/-HackerOne-%23494649?style=for-the-badge\&logo=hackerone\&logoColor=white)](https://hackerone.com/phaedrusflow)
		[![HuggingFace](https://img.shields.io/badge/HuggingFace-qompass-yellow?style=flat-square\&logo=huggingface)](https://huggingface.co/qompass)
		[![Epic Games
		Developer](https://img.shields.io/badge/Epic_Games-Developer_Program-313131?style=for-the-badge\&logo=epic-games\&logoColor=white)](https://dev.epicgames.com/)

		<h3>Professional Profiles</h3>
		<p>
			<a href="https://www.linkedin.com/in/matt-a-porter-103535224/">
				<img src="https://img.shields.io/badge/LinkedIn-Owner-blue?style=flat-square&logo=linkedin"
					alt="Personal LinkedIn">
			</a>
			<a href="https://www.linkedin.com/company/95058568/">
				<img src="https://img.shields.io/badge/LinkedIn-Qompass--AI-blue?style=flat-square&logo=linkedin"
					alt="Startup LinkedIn">
			</a>
		</p>

		<h3>Social Media</h3>
		<p>
			<a href="https://twitter.com/PhaedrusFlow">
				<img src="https://img.shields.io/badge/Twitter-@PhaedrusFlow-blue?style=flat-square&logo=twitter"
					alt="X/Twitter">
			</a>
			<a href="https://www.instagram.com/phaedrusflow">
				<img src="https://img.shields.io/badge/Instagram-phaedrusflow-purple?style=flat-square&logo=instagram"
					alt="Instagram">
			</a>
			<a href="https://www.youtube.com/@qompassai">
				<img src="https://img.shields.io/badge/YouTube-QompassAI-red?style=flat-square&logo=youtube"
					alt="Qompass AI YouTube">
			</a>
		</p>

	</blockquote>
</details>

<details>
	<summary
		style="font-size: 1.4em; font-weight: bold; padding: 15px; background: #ff6b6b; color: white; border-radius: 10px; cursor: pointer; margin: 10px 0;">
		<strong>🔥 How Do I Support</strong>
	</summary>
	<blockquote
		style="font-size: 1.2em; line-height: 1.8; padding: 25px; background: #fff5f5; border-left: 6px solid #ff6b6b; border-radius: 8px; margin: 15px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">

		<div align="center">

			<table>
				<tr>
					<th align="center">🏛️ Qompass AI Pre-Seed Funding 2023-2025</th>
					<th align="center">🏆 Amount</th>
					<th align="center">📅 Date</th>
				</tr>
				<tr>
					<td><a href="https://github.com/qompassai/r4r"
							title="RJOS/Zimmer Biomet Research Grant Repository">RJOS/Zimmer Biomet Research Grant</a>
					</td>
					<td align="center">$30,000</td>
					<td align="center">March 2024</td>
				</tr>
				<tr>
					<td><a href="https://github.com/qompassai/PathFinders" title="GitHub Repository">Pathfinders Intern
							Program</a><br>
						<small><a
								href="https://www.linkedin.com/posts/evergreenbio_bioscience-internships-workforcedevelopment-activity-7253166461416812544-uWUM/"
								target="_blank">View on LinkedIn</a></small>
					</td>
					<td align="center">$2,000</td>
					<td align="center">October 2024</td>
				</tr>
			</table>

			<br>
			<h4>🤝 How To Support Our Mission</h4>

			[![GitHub
			Sponsors](https://img.shields.io/badge/GitHub-Sponsor-EA4AAA?style=for-the-badge\&logo=github-sponsors\&logoColor=white)](https://github.com/sponsors/phaedrusflow)
			[![Patreon](https://img.shields.io/badge/Patreon-Support-F96854?style=for-the-badge\&logo=patreon\&logoColor=white)](https://patreon.com/qompassai)
			[![Liberapay](https://img.shields.io/badge/Liberapay-Donate-F6C915?style=for-the-badge\&logo=liberapay\&logoColor=black)](https://liberapay.com/qompassai)
			[![Open
			Collective](https://img.shields.io/badge/Open%20Collective-Support-7FADF2?style=for-the-badge\&logo=opencollective\&logoColor=white)](https://opencollective.com/qompassai)
			[![Buy Me A
			Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support-FFDD00?style=for-the-badge\&logo=buy-me-a-coffee\&logoColor=black)](https://www.buymeacoffee.com/phaedrusflow)

			<details markdown="1">
				<summary><strong>🔐 Cryptocurrency Donations</strong></summary>

				**Monero (XMR):**

				<div align="center">
					<img src="./assets/monero-qr.png" alt="Monero QR Code" width="180">
				</div>

				<div style="margin: 10px 0;">
					<code>42HGspSFJQ4MjM5ZusAiKZj9JZWhfNgVraKb1eGCsHoC6QJqpo2ERCBZDhhKfByVjECernQ6KeZwFcnq8hVwTTnD8v4PzyH</code>
				</div>

				<button
					onclick="navigator.clipboard.writeText('42HGspSFJQ4MjM5ZusAiKZj9JZWhfNgVraKb1eGCsHoC6QJqpo2ERCBZDhhKfByVjECernQ6KeZwFcnq8hVwTTnD8v4PzyH')"
					style="padding: 6px 12px; background: #FF6600; color: white; border: none; border-radius: 4px; cursor: pointer;">
					📋 Copy Address
				</button>
				<p><i>Funding helps us continue our research at the intersection of AI, healthcare, and education</i>
				</p>

	</blockquote>
</details>
</details>

<details id="FAQ">
	<summary><strong>Frequently Asked Questions</strong></summary>

	### Q: How do you mitigate against bias?

	**TLDR - we do math to make AI ethically useful**

	### A: We delineate between mathematical bias (MB) - a fundamental parameter in neural network equations - and
	algorithmic/social bias (ASB). While MB is optimized during model training through backpropagation, ASB requires
	careful consideration of data sources, model architecture, and deployment strategies. We implement attention
	mechanisms for improved input processing and use legal open-source data and secure web-search APIs to help mitigate
	ASB.

	[AAMC AI Guidelines | One way to align AI against
	ASB](https://www.aamc.org/about-us/mission-areas/medical-education/principles-ai-use)

	### AI Math at a glance

	## Forward Propagation Algorithm

	$$
	y = w_1x_1 + w_2x_2 + ... + w_nx_n + b
	$$

	Where:

	- $y$ represents the model output
	- $(x_1, x_2, ..., x_n)$ are input features
	- $(w_1, w_2, ..., w_n)$ are feature weights
	- $b$ is the bias term

	### Neural Network Activation

	For neural networks, the bias term is incorporated before activation:

	$$
	z = \\sum\_{i=1}^{n} w_ix_i + b
	$$
	$$
	a = \\sigma(z)
	$$

	Where:

	- $z$ is the weighted sum plus bias
	- $a$ is the activation output
	- $\\sigma$ is the activation function

	### Attention Mechanism- aka what makes the Transformer (The "T" in ChatGPT) powerful

	- [Attention High level overview video](https://www.youtube.com/watch?v=fjJOgb-E41w)

	- [Attention Is All You Need Arxiv Paper](https://arxiv.org/abs/1706.03762)

	The Attention mechanism equation is:

	$$
	\\text{Attention}(Q, K, V) = \\text{softmax}\\left( \\frac{QK^T}{\\sqrt{d_k}} \\right) V
	$$

	Where:

	- $Q$ represents the Query matrix
	- $K$ represents the Key matrix
	- $V$ represents the Value matrix
	- $d_k$ is the dimension of the key vectors
	- $\\text{softmax}(\\cdot)$ normalizes scores to sum to 1

	### Q: Do I have to buy a Linux computer to use this? I don't have time for that!

	### A: No. You can run Linux and/or the tools we share alongside your existing operating system:

	- Windows users can use Windows Subsystem for Linux [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
	- Mac users can use [Homebrew](https://brew.sh/)
	- The code-base instructions were developed with both beginners and advanced users in mind.

	### Q: Do you have to get a masters in AI?

	### A: Not if you don't want to. To get competent enough to get past ChatGPT dependence at least, you just need a
	computer and a beginning's mindset. Huggingface is a good place to start.

	- [Huggingface](https://docs.google.com/presentation/d/1IkzESdOwdmwvPxIELYJi8--K3EZ98_cL6c5ZcLKSyVg/edit#slide=id.p)

	### Q: What makes a "small" AI model?

	### A: AI models ~=10 billion(10B) parameters and below. For comparison, OpenAI's GPT4o contains approximately 200B
	parameters.

</details>

## License

This project is licensed under the [Apache License, Version 2.0](./LICENSE).
