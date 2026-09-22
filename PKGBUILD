# Maintainer: Danish <danishmeraj385@gmail.com>
pkgname=wispertype
pkgver=0.1.0
pkgrel=1
pkgdesc="Offline system-wide voice-to-text dictation tool for Wayland"
arch=('x86_64' 'aarch64')
url="https://github.com/Danish-labs/WisperType"
license=('MIT')
depends=('gtk4' 'libadwaita' 'pipewire' 'wtype')
makedepends=('cargo' 'git')
source=("git+$url.git#branch=main")
sha256sums=('SKIP')

build() {
  cd "WisperType"
  cargo build --release
}

package() {
  cd "WisperType"
  install -Dm755 "target/release/$pkgname" "$pkgdir/usr/bin/$pkgname"
  if [ -f "wispertype.desktop" ]; then
    install -Dm644 "wispertype.desktop" "$pkgdir/usr/share/applications/wispertype.desktop"
  fi
}
