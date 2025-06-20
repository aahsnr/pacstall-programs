#!/usr/bin/bash
# shellcheck disable=2034
#-*- mode: sh-*-
#  __      __________   ______
# /  \    /  \_____  \ /  __  \
# \   \/\/   //  ____/ >      <
#  \        //       \/   --   \
#   \__/\  / \_______ \______  /
#        \/          \/      \/
maintainer=("wizard-28 <wiz28@pm.me>")

### This pacscript is made with (ported to pacstall) the help of https://aur.archlinux.org/cgit/aur.git/commit/?h=emacs-git&id=b9eb3b405717f8df37b38217dbb7d361b8ffca08
###################################################################################
# Assign "YES" to the variable you want enabled; empty or any other value
# for NO.
#
# Where you read experimental, replace with foobar.
# =================================================
#
################################################################################
CLANG=            # Use clang.

GOLD=             # Use the gold linker.

LTO=              # Enable link-time optimization. Still experimental.

JIT="YES"         # Enable native just-in-time compilation. libgccjit is in AUR.
                  # This compiles only performance critical elisp files.
                  #
                  # To compile all site-lisp on demand (repos/AUR packages,
                  # ELPA, MELPA, whatever), add
                  #    (setq comp-deferred-compilation t)
                  # to your .emacs file.

AOT="YES"         # Compile all elisp files.

CLI=              # CLI only binary.

GPM=              # Mouse support in Linux console using gpmd.

NOTKIT=           # Use no toolkit widgets. Like B&W Twm (001d sk00l).
                  # Bitmap fonts only, 1337!

PGTK="YES"             # Use native GTK3 build. Supports Wayland, yay!

GTK3=             # GTK3 old windowing interface.

LUCID=            # Use the lucid, a.k.a athena, toolkit. Like XEmacs, sorta.
                  #
                  # Read https://wiki.archlinux.org/index.php/X_resources
                  # https://en.wikipedia.org/wiki/X_resources
                  # and https://www.emacswiki.org/emacs/XftGnuEmacs
                  # for some tips on using outline fonts with
                  # Xft, if you choose no toolkit or Lucid.

XI2="YES"         # Use Xinput2 support.
                  # https://www.x.org/releases/X11R7.7/doc/inputproto/XI2proto.txt

ALSA=             # Linux sound support.

NOCAIRO=          # Disable here.

XWIDGETS=         # Use GTK+ widgets pulled from webkit2gtk. Usable.

DOCS_HTML=        # Generate and install html documentation.

DOCS_PDF=         # Generate and install pdf documentation.

NOGZ="YES"        # Don't compress .el files.
#################################################################################

pkgname="emacs"
arch=("any")
pkgver="30.1"
source=("@${pkgname}~${pkgver}::http://ftpmirror.gnu.org/emacs/emacs-${pkgver}.tar.xz")
pkgdesc="An extensible, customizable, free/libre text editor — and more."
makedepends=("git" "autoconf" "texinfo" "pkg-config" "libncurses-dev" "libjpeg-dev" "libpng-dev" "libtiff-dev" "libgnutls28-dev" "libgif-dev" "libxaw7-dev" "libxpm-dev" "libtree-sitter-dev")
depends_nox=("libalsaplayer0" "libgnutls28-dev" "libxml2" "libjansson-dev" "gpm")
depends=("${depends_nox[@]}" "m17n-lib-bin" "libharfbuzz0b")
gives="${pkgname}"
breaks=("${pkgname}-git" "${pkgname}-nox")
replaces=("${pkgname}-git" "${pkgname}-nox")
sha256sums=("6ccac1ae76e6af93c6de1df175e8eb406767c23da3dd2a16aa67e3124a6f138f")
repology=("project: emacs")

if [[ ${GOLD} == "YES" && ${CLANG} != "YES" ]]; then
  export LD=/usr/bin/ld.gold
  export CFLAGS+=" -fuse-ld=gold"
  export CXXFLAGS+=" -fuse-ld=gold"
elif [[ ${GOLD} == "YES" && ${CLANG} == "YES" ]]; then
  fancy_message error "Clang rather uses its own linker."
  exit 1
fi
if [[ ${CLANG} == "YES" ]]; then
  export CC="/usr/bin/clang"
  export CXX="/usr/bin/clang++"
  export CPP="/usr/bin/clang -E"
  export LD="/usr/bin/lld"
  export AR="/usr/bin/llvm-ar"
  export AS="/usr/bin/llvm-as"
  export CCFLAGS+=" -fuse-ld=lld"
  export CXXFLAGS+=" -fuse-ld=lld"
  makedepends+=("clang" "lld" "llvm")
fi
if [[ ${LTO} == "YES" ]]; then
  if [[ ${CLANG} != "YES" ]]; then
    CFLAGS+=" -flto -fuse-linker-plugin"
    CXXFLAGS+=" -flto -fuse-linker-plugin"
  else
    CFLAGS+=" -flto"
    CXXFLAGS+=" -flto"
  fi
fi

if [[ ${JIT} == "YES" ]]; then
  if [[ ${CLI} == "YES" ]]; then
    depends_nox+=("libgccjit0" "libgccjit-14-dev")
  else
    depends+=("libgccjit0" "libgccjit-14-dev")
  fi
fi

if [[ ${CLI} == "YES" ]]; then
  depends=("${depends_nox[@]}")
elif [[ ${NOTKIT} == "YES" ]]; then
  depends+=("dbus" "hicolor-icon-theme" "libxinerama1" "libxrandr2" "liblcms2-2" "librsvg2-2" "libxfixes3" "libxi6" "libsm6" "libxcb-util1" "libxcb1")
  makedepends+=("x11proto-dev")
elif [[ ${LUCID} == "YES" ]]; then
  depends+=("dbus" "hicolor-icon-theme" "libxinerama1" "libxfixes3" "liblcms2-2" "librsvg2-2" "xaw3dg" "libxrandr2" "libxi6" "libsm6" "libxcb-util1" "libxcb1")
  makedepends+=("x11proto-dev")
elif [[ ${GTK3} == "YES" ]]; then
  depends+=("libgtk-4-dev | libgtk-3-dev" "libsm6" "libxcb-util1" "libxcb1")
  makedepends+=("x11proto-dev" "libxi-dev")
fi

if [[ ${CLI} != "YES" ]]; then
  depends+=("libjpeg-turbo8 | libjpeg62-turbo" "libpng16-16" "libgif-dev" "libwebp7 | libweb6" "libtiff6 | libtiff5")
elif [[ ${CLI} == "YES" ]]; then
  depends+=("")
fi

if [[ ${ALSA} == "YES" ]]; then
  if [[ ${CLI} == "YES" ]]; then
    depends_nox+=("libasound2" "libatopology2")
  else
    depends+=("libasound2" "libatopology2")
  fi
fi

if [[ ${NOCAIRO} != "YES" && ${CLI} != "YES" && ${PGTK} != "YES" ]]; then
  depends+=("libcairo2")
fi

if [[ ${XWIDGETS} == "YES" ]]; then
  if [[ ${LUCID} == "YES" || ${NOTKIT} == "YES" || ${CLI} == "YES" ]]; then
    fancy_message error "Xwidgets support *requires* gtk+3!!!"
    exit 1
  else
    depends+=("libwebkit2gtk-4.0-37")
  fi
fi

if [[ ${GPM} == "YES" ]]; then
  if [[ ${CLI} == "YES" ]]; then
    depends_nox+=("libgpm2")
  else
    depends+=("libgpm2")
  fi
fi

if [[ ${DOCS_PDF} == "YES" && ! -d "/usr/local/texlive" ]]; then
  makedepends+=("texlive-base")
fi

prepare() {
  cd "${pkgname}~${pkgver}"
  [[ -x configure ]] || (./autogen.sh git && ./autogen.sh autoconf)
}

build() {
  cd "${pkgname}~${pkgver}"
  local _conf=(
    --disable-build-details
    --with-mailutils
    --with-imagemagick
    --with-tree-sitter
    --with-modules
    --with-threads
    --with-sqlite3
    --with-cairo
    --with-harfbuzz
    --with-libsystemd
  )
  if [[ ${CLANG} == "YES" ]]; then
    _conf+=("--enable-autodepend")
  fi

  if [[ ${LTO} == "YES" ]]; then
    _conf+=("--enable-link-time-optimization")
  fi

  if [[ ${JIT} == "YES" ]]; then
    _conf+=("--with-native-compilation=aot")
  fi

  if [[ ${XI2} == "YES" ]]; then
    _conf+=("--with-xinput2")
  fi

  if [[ ${CLI} == "YES" ]]; then
    _conf+=("--without-x" "--with-x-toolkit=no" "--without-xft" "--without-lcms2" "--without-rsvg" "--without-jpeg" "--without-gif" "--without-tiff" "--without-png")
  elif [[ ${NOTKIT} == "YES" ]]; then
    _conf+=("--with-x-toolkit=no" "--without-toolkit-scroll-bars" "--without-xft" "--without-xaw3d")
  elif [[ ${LUCID} == "YES" ]]; then
    _conf+=("--with-x-toolkit=lucid" "--with-xft" "--with-xaw3d")
  elif [[ ${GTK3} == "YES" ]]; then
    _conf+=("--with-x-toolkit=gtk3" "--without-xaw3d")
  elif [[ ${PGTK} == "YES" ]]; then
    _conf+=("--with-pgtk" "--without-xaw3d")
  fi

  if [[ ${PGTK} != "YES" ]]; then
    _conf+=("--without-gsettings")
  fi

  if [[ ${NOCAIRO} == "YES" || ${CLI} == "YES" || ${NOTKIT} == "YES" || ${LUCID} == "YES" ]]; then
    _conf+=("--without-cairo")
  fi

  if [[ ${ALSA} == "YES" ]]; then
    _conf+=("--with-sound=alsa")
  else
    _conf+=("--with-sound=no")
  fi

  if [[ ${XWIDGETS} == "YES" ]]; then
    _conf+=("--with-xwidgets")
  fi

  if [[ ${GPM} != "YES" ]]; then
    _conf+=("--without-gpm")
  fi

  if [[ ${NOGZ} == "YES" ]]; then
    _conf+=("--without-compress-install")
  fi

  # ctags/etags may be provided by other packages, e.g, universal-ctags
  _conf+=("--program-transform-name=s/\([ec]tags\)/\1.emacs/")

  ./configure "${_conf[@]}"

  # Using "make" instead of "make bootstrap" enables incremental
  # compiling. Less time recompiling. Yay! But you may
  # need to use bootstrap sometimes to unbreak the build.
  # Just add it to the command line.
  #
  # Please note that incremental compilation implies that you
  # are reusing your src directory!

  if [[ ${JIT} == "YES" && ${AOT} == "YES" ]]; then
    make -j"${NCPU}" NATIVE_FULL_AOT=1
  else
    make -j"${NCPU}"
  fi

  # You may need to run this if "loaddefs.el" files become corrupt.
  #cd "/usr/pacstall/src/emacs-git/lisp"
  #make autoloads
  #cd "${srcdir}"/

  # Optional documentation formats.
  if [[ ${DOCS_HTML} == "YES" ]]; then
    make -j"${NCPU}" html
  fi
  if [[ ${DOCS_PDF} == "YES" ]]; then
    make -j"${NCPU}" pdf
  fi

}

package() {
  cd "${pkgname}~${pkgver}"
  make -j"${NCPU}" DESTDIR="${pkgdir}" install

  # Install optional documentation formats
  if [[ ${DOCS_HTML} == "YES" ]]; then make -j"${NCPU}" DESTDIR="${pkgdir}" install-html; fi
  if [[ ${DOCS_PDF} == "YES" ]]; then make -j"${NCPU}" DESTDIR="${pkgdir}" install-pdf; fi

  # fix user/root permissions on usr/local/share files
  mkdir -p "${pkgdir}/usr/share/emacs/"
  find "${pkgdir}/usr/share/emacs/" -print0 | xargs -0 chown root:root

  # fix permssions on /var/games
  mkdir -p "${pkgdir}/var/games/emacs"
  chmod 775 "${pkgdir}/var/games"
  chmod 775 "${pkgdir}/var/games/emacs"
}
# vim:set ft=sh ts=2 sw=2 et:
