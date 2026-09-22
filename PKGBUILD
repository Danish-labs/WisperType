# Maintainer: Danish <danishmeraj385@gmail.com>
pkgname=wispertype
pkgver=0.1.0
pkgrel=1
pkgdesc="Offline local speech-to-text dictation tool for Linux desktops"
arch=('x86_64' 'aarch64')
url="https://github.com/Danish-labs/WisperType"
license=('MIT')
depends=('curl' 'pipewire' 'wtype')
makedepends=('cargo' 'git' 'clang' 'cmake')
source=(
  "git+$url.git#branch=main"
  "wispertype.service"
  "wispertype.install"
  "install-model.sh"
)
sha256sums=('SKIP' 'SKIP' 'SKIP' 'SKIP')

prepare() {
  cd "$srcdir/WisperType"
  cargo fetch
}

build() {
  cd "$srcdir/WisperType"
  cargo build --release --locked
}

package() {
  cd "$srcdir/WisperType"

  install -Dm755 "target/release/$pkgname" "$pkgdir/usr/bin/$pkgname"

  if [ -f "$srcdir/wispertype.service" ]; then
    install -Dm644 "$srcdir/wispertype.service" "$pkgdir/usr/lib/systemd/user/wispertype.service"
  fi

  if [ -f "$srcdir/wispertype.install" ]; then
    install -Dm755 "$srcdir/wispertype.install" "$pkgdir/usr/lib/wispertype/post-install"
  fi

  if [ -f "$srcdir/install-model.sh" ]; then
    install -Dm755 "$srcdir/install-model.sh" "$pkgdir/usr/lib/wispertype/install-model.sh"
  fi

  if [ -f "wispertype.desktop" ]; then
    install -Dm644 "wispertype.desktop" "$pkgdir/usr/share/applications/wispertype.desktop"
  fi
}

post_install() {
  systemctl --user daemon-reload >/dev/null 2>&1 || true
  /usr/lib/wispertype/install-model.sh >/dev/null 2>&1 || true
  systemctl --user enable --now wispertype.service >/dev/null 2>&1 || true
}

post_upgrade() {
  systemctl --user daemon-reload >/dev/null 2>&1 || true
  /usr/lib/wispertype/install-model.sh >/dev/null 2>&1 || true
  systemctl --user restart wispertype.service >/dev/null 2>&1 || true
}
