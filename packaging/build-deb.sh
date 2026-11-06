#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Gera o pacote .deb do Kurumin Pulso (Debian, Ubuntu, Sururu Linux e derivados).
# Uso: bash packaging/build-deb.sh   ->  dist/kurumin-pulso_<versão>_all.deb
set -euo pipefail

raiz="$(cd "$(dirname "$0")/.." && pwd)"
versao="$(grep -m1 '^VERSAO = ' "$raiz/kurumin-pulso" | cut -d'"' -f2)"
pkg="$(mktemp -d)"
chmod 755 "$pkg"
trap 'rm -rf "$pkg"' EXIT

install -Dm755 "$raiz/kurumin-pulso" "$pkg/usr/bin/kurumin-pulso"
install -Dm644 "$raiz/README.md" "$pkg/usr/share/doc/kurumin-pulso/README.md"

cat > "$pkg/usr/share/doc/kurumin-pulso/copyright" <<EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: kurumin-pulso
Upstream-Contact: Kurumin Tecnologia <contato@kurumintecnologia.com.br>
Source: https://github.com/kurumintecnologia/kurumin-pulso

Files: *
Copyright: 2026 Tácio Souza de Oliveira / Kurumin Tecnologia
License: GPL-3+
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 .
 On Debian systems, the complete text of the GNU General Public License
 version 3 can be found in "/usr/share/common-licenses/GPL-3".
EOF

mkdir -p "$pkg/DEBIAN"
cat > "$pkg/DEBIAN/control" <<EOF
Package: kurumin-pulso
Version: $versao
Section: net
Priority: optional
Architecture: all
Depends: python3 (>= 3.9), iproute2, iputils-ping
Recommends: iw
Maintainer: Tácio Souza de Oliveira <contato@kurumintecnologia.com.br>
Homepage: https://github.com/kurumintecnologia/kurumin-pulso
Description: teste de rede em um comando, com relatório e histórico
 Kurumin Pulso mede latência, jitter, perda de pacotes, DNS, download e
 upload, diz em português se o problema está na rede de casa ou no
 provedor e gera um relatório HTML com gráficos e histórico para comparar
 cabo, Wi-Fi e horários. Nenhum IP é gravado por padrão.
EOF

mkdir -p "$raiz/dist"
saida="$raiz/dist/kurumin-pulso_${versao}_all.deb"
dpkg-deb --build --root-owner-group "$pkg" "$saida" >/dev/null
echo "$saida"
