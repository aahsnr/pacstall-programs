pkgbase="nerd-fonts"
pkgname=(
  "ttf-nerd-fonts-symbols"
  "ttf-jetbrains-mono-nerd"
  "ttf-ubuntu-mono-nerd"
  "ttf-ubuntu-nerd"
)
pkgdesc="Iconic font aggregator, collection, and patcher"
arch=("all")
pkgver="3.4.0"
url='https://github.com/ryanoasis/nerd-fonts'
_urlbase="${url}/releases/download/v${pkgver}"
license=('MIT' 'OFL-1.1')
provides=('ttf-font-nerd')
maintainer=("Ahsanur Rahman <ahsanur041@proton.me")
source=(
  "symbolsonly-${pkgver}.tar.xz::${_urlbase}/NerdFontsSymbolsOnly.tar.xz"
  "jetbrainsmono-${pkgver}.tar.xz::${_urlbase}/JetBrainsMono.tar.xz"
  "ubuntu-${pkgver}.tar.xz::${_urlbase}/Ubuntu.tar.xz"
  "ubuntumono-${pkgver}.tar.xz::${_urlbase}/UbuntuMono.tar.xz"
)
sha256sums=(
  '7f8c090da3b0eaa7108646bf34cbbb6ed13d5358a72460522108b06c7ecd716a'
  'ef552a3e638f25125c6ad4c51176a6adcdce295ab1d2ffacf0db060caf8c1582'
  '534bf0ffb311a993fd23666a7f3e4f4a0cfc0662abfa8b81594705cceefb69e3'
  'a13cf890ef10517c59e812ced167245f2db47d37d2b03c9fb43ddef023a3e776'
)
noextract=("${source[@]%%::*}")

prepare() {
  # archives don't include a font-specific directory, so we have to make them
  for _font in  jetbrainsmono ubuntu ubuntumono; do
    rm -rf "${_font}"
    mkdir -p "${_font}"
    tar -xf "${_font}-${pkgver}.tar.xz" -C "${_font}"
  done
}

package_ttf-nerd-fonts-symbols() {
  pkgdesc="Patched font JetBrains Mono from nerd fonts library"
  license=('MIT')
  conflicts=(nerd-fonts-symbols)
  replaces=(nerd-fonts-symbols)

  install -Dm644 symbolsonly/*.ttf -t "${pkgdir}/usr/share/fonts/TTF"
  install -Dm644 symbolsonly/LICENSE -t "${pkgdir}/usr/share/licenses/${pacname}/"
}

package_ttf-jetbrains-mono-nerd() {
  pkgdesc="Patched font JetBrains Mono from nerd fonts library"
  license=('OFL-1.1-no-RFN')
  conflicts=(nerd-fonts-jetbrains-mono)
  replaces=(nerd-fonts-jetbrains-mono)

  install -Dm644 jetbrainsmono/*.ttf -t "${pkgdir}/usr/share/fonts/TTF"
  install -Dm644 jetbrainsmono/OFL.txt -t "${pkgdir}/usr/share/licenses/${pacname}/"
}

package_ttf-ubuntu-mono-nerd() {
  pkgdesc="Patched font Ubuntu Mono from nerd fonts library"
  license=('custom:LicenseRef-Ubuntu-Font-License-1.0')
  conflicts=(nerd-fonts-ubuntu-mono ttf-ubuntumono-nerd)
  replaces=(nerd-fonts-ubuntu-mono ttf-ubuntumono-nerd)

  install -Dm644 ubuntumono/*.ttf -t "${pkgdir}/usr/share/fonts/TTF"
  install -Dm644 ubuntumono/LICENCE.txt -t "${pkgdir}/usr/share/licenses/${pacname}/"
}

package_ttf-ubuntu-nerd() {
  pkgdesc="Patched font Ubuntu from nerd fonts library"
  license=('custom:LicenseRef-Ubuntu-Font-License-1.0')
  conflicts=(nerd-fonts-ubuntu)
  replaces=(nerd-fonts-ubuntu)

  install -Dm644 ubuntu/*.ttf -t "${pkgdir}/usr/share/fonts/TTF"
  install -Dm644 ubuntu/LICENCE.txt -t "${pkgdir}/usr/share/licenses/${pacname}/"
}
