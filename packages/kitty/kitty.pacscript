pkgname="kitty"
arch=("any")
pkgver="0.42.1"
repology=("project: kitty")
source=("@${pkgname}~${pkgver}::https://github.com/kovidgoyal/kitty/archive/refs/tags/v${pkgver}.tar.gz")
makedepends=("golang-go" "python3" "python3-dev" "build-essential" "pkg-config" "libcairo2-dev" "libdbus-1-dev" "libfreetype6-dev" "libfontconfig1-dev" "libharfbuzz-dev" "liblcms2-dev" "libgl1-mesa-dev" "libpng-dev" "librsync-dev" "libx11-dev" "libxcursor-dev" "libxkbcommon-dev" "libxkbcommon-x11-dev" "libxi-dev" "libssl-dev" "libwayland-dev" "libxxhash-dev" "zlib1g-dev" "libxinerama-dev" "libxrandr-dev" "wayland-protocols" "ncurses-base" "dpkg-dev")
depends=("libcairo2" "libdbus-1-3" "libfreetype6" "libfontconfig1" "libharfbuzz0b" "liblcms2-2" "glx-alternative-mesa" "libpng16-16" "librsync2" "libx11-6" "libxcursor1" "libxkbcommon0" "libxkbcommon-x11-0" "libxi6" "libssl3" "python3" "libwayland-client0" "libxxhash0" "zlib1g")
pkgdesc="A modern, hackable, featureful, OpenGL-based terminal emulator"
maintainer=("Ahsanur <ahsanur041@proton.me>")
incompatible=('debian:bookworm')
external_connection=true
# Note: Checksums should be verified for the specific version
sha256sums=("d766e7789863dc4c7393cc471a2962838904558b9be54587abbd9cd8fa89bbbb")

build() {
  cd "${pkgname}~${pkgver}"

  # Get Debian build flags
  export CPPFLAGS="$(dpkg-buildflags --get CPPFLAGS)"
  export CFLAGS="$(dpkg-buildflags --get CFLAGS)"
  export CXXFLAGS="$(dpkg-buildflags --get CXXFLAGS)"
  export LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"

  # Set Go environment variables for building
  export CGO_CPPFLAGS="${CPPFLAGS}"
  export CGO_CFLAGS="${CFLAGS}"
  export CGO_CXXFLAGS="${CXXFLAGS}"
  export CGO_LDFLAGS="${LDFLAGS}"
  export GOFLAGS="-buildmode=pie -trimpath -ldflags=-linkmode=external -mod=readonly -modcacherw"

  # Build kitty
  python3 setup.py linux-package --update-check-interval=0
}

package() {
  cd "${pkgname}~${pkgver}"

  # Install main kitty package
  cp -r linux-package "${pkgdir}"/usr

  # Generate and install shell completions
  mkdir -p "${pkgdir}/usr/share/bash-completion/completions"
  mkdir -p "${pkgdir}/usr/share/fish/vendor_completions.d"
  mkdir -p "${pkgdir}/usr/share/zsh/site-functions"

  linux-package/bin/kitten __complete__ setup bash > "${pkgdir}/usr/share/bash-completion/completions/kitty"
  linux-package/bin/kitten __complete__ setup fish > "${pkgdir}/usr/share/fish/vendor_completions.d/kitty.fish"
  linux-package/bin/kitten __complete__ setup zsh > "${pkgdir}/usr/share/zsh/site-functions/_kitty"

  # Install pixmap icon
  install -Dm644 "${pkgdir}/usr/share/icons/hicolor/256x256/apps/kitty.png" "${pkgdir}/usr/share/pixmaps/kitty.png"

  # Install terminfo
  mkdir -p "${pkgdir}/usr/share/terminfo"
  tic -x -o "${pkgdir}/usr/share/terminfo" terminfo/kitty.terminfo

  # Install shell integration scripts
  mkdir -p "${pkgdir}/usr/lib/kitty/"
  cp -r shell-integration "${pkgdir}/usr/lib/kitty/"

  # Install documentation
  mkdir -p "${pkgdir}/usr/share/doc/${pkgname}"
  if [ -f "docs/_build/html/_downloads/*/kitty.conf" ]; then
    install -Dm644 docs/_build/html/_downloads/*/kitty.conf "${pkgdir}/usr/share/doc/${pkgname}/kitty.conf"
  fi

  sudo apt autoremove
}
