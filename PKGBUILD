# Maintainer: Danish <your.email@example.com>
pkgname=wispertype
pkgver=0.1.0
pkgrel=1
pkgdesc="Offline system-wide voice-to-text dictation tool for Wayland"
arch=('x86_64' 'aarch64')
url="https://github.com/Danish-labs/WisperType"
license=('MIT')
depends=('gtk4' 'libadwaita' 'pipewire' 'wtype' 'gcc-libs')
makedepends=('cargo' 'git' 'clang' 'cmake')
source=("$pkgname-$pkgver.tar.gz::$url/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('SKIP')

build() {
  cd "WisperType-$pkgver"
  
  # Set C++ linker flags to resolve native C++ symbols in whisper-rs
  export RUSTFLAGS="-C link-arg=-lstdc++"
  
  cargo build --release --locked
}

package() {
  cd "WisperType-$pkgver"
  install -Dm755 "target/release/$pkgname" "$pkgdir/usr/bin/$pkgname"
  install -Dm644 "wispertype.desktop" "$pkgdir/usr/share/applications/wispertype.desktop"
}
