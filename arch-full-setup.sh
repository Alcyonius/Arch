#!/usr/bin/env bash
set -euo pipefail

echo "🔥 Arch Full Setup Starting..."

# -------------------------
# Helper
# -------------------------
have() { pacman -Qi "$1" &>/dev/null; }
install_pkgs() {
  local to_install=()
  for p in "$@"; do
    if have "$p"; then
      echo "✓ $p already installed"
    else
      to_install+=("$p")
    fi
  done
  if ((${#to_install[@]})); then
    sudo pacman -S --noconfirm --needed "${to_install[@]}"
  fi
}

# -------------------------
# Update system
# -------------------------
sudo pacman -Syu --noconfirm

# -------------------------
# Core system + dev
# -------------------------
install_pkgs git base-devel neovim zsh tmux \
  wget curl unzip ripgrep fd \
  ttf-dejavu ttf-liberation ttf-crimson

# -------------------------
# Enable multilib (for Steam)
# -------------------------
if ! grep -q "\[multilib\]" /etc/pacman.conf; then
  sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
  sudo pacman -Syu --noconfirm
fi

# -------------------------
# Gaming
# -------------------------
install_pkgs steam mangohud

mkdir -p ~/.local/bin
cat > ~/.local/bin/prime-run <<'EOF'
#!/bin/bash
__NV_PRIME_RENDER_OFFLOAD=1 \
__GLX_VENDOR_LIBRARY_NAME=nvidia \
__VK_LAYER_NV_optimus=NVIDIA_only \
exec "$@"
EOF
chmod +x ~/.local/bin/prime-run

# -------------------------
# Docker
# -------------------------
install_pkgs docker docker-compose
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# -------------------------
# k3s
# -------------------------
if ! command -v k3s &>/dev/null; then
  curl -sfL https://get.k3s.io | sh -
fi

# -------------------------
# Monitoring stack (Docker Compose - stable way)
# -------------------------
mkdir -p ~/monitoring
cat > ~/monitoring/docker-compose.yml <<'EOF'
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
EOF

cd ~/monitoring
docker compose up -d || true

# -------------------------
# Academic stack
# -------------------------
install_pkgs zettlr pandoc \
  texlive-basic texlive-latexextra texlive-fontsextra

mkdir -p ~/.local/share/Zettlr/templates ~/zettlr/csl

curl -L -o ~/zettlr/csl/harvard.csl \
  https://www.zotero.org/styles/harvard-cite-them-right

cat > ~/.local/share/Zettlr/templates/uni-template.md <<'EOF'
---
title: "Assignment"
author: "Your Name"
bibliography: ~/zettlr/references.bib
csl: ~/zettlr/csl/harvard.csl
---

# Title

## Introduction

[@example]
EOF

cat > ~/zettlr/references.bib <<'EOF'
@article{example,
  title={Example},
  author={Smith, John},
  year={2024}
}
EOF

# -------------------------
# Neovim config
# -------------------------
mkdir -p ~/.config/nvim
cat > ~/.config/nvim/init.vim <<'EOF'
set number
syntax on
set tabstop=2
set shiftwidth=2
set expandtab
EOF

echo "✅ Setup complete!"
echo "⚠️ Reboot recommended"
