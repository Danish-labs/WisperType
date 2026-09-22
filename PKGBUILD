# Maintainer: Your Name <your.email@example.com>
pkgname=wispertype
pkgver=0.1.0
pkgrel=1
pkgdesc="Offline system-wide voice-to-text dictation tool for Wayland"
arch=('x86_64' 'aarch64')
url="https://github.com/yourusername/wispertype"
license=('MIT')
depends=('gtk4' 'libadwaita' 'pipewire' 'wtype')
makedepends=('cargo' 'git' 'clang' 'cmake')
source=("$pkgname-$pkgver.tar.gz::$url/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('SKIP')

build() {
  cd "$pkgname-$pkgver"
  cargo build --release --locked
}

package() {
  cd "$pkgname-$pkgver"
  install -Dm755 "target/release/$pkgname" "$pkgdir/usr/bin/$pkgname"
}
