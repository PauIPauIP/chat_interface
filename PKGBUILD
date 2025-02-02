# Maintainer: Paul paul@liphium.dev
pkgname="liphium-git"
pkgver=1.0.0
pkgrel=1
pkgdesc="A chat app that's fun again, while also being secure."
arch=('x86_64')
url="https://github.com/PauIPauIP/chat_interface/tree/master"  # project URL, I think thats the correct one
license=('Apache')  # Apache2 also works
depends=('gtk3' 'other-dependencies')  # dependencies
makedepends=('build-tools')  # required dependencies for building
source=("path/to/your/source/files"
        "path/to/your/icons/liphium.png"
        "path/to/your/com.liphium.Liphium.desktop")
sha256sums=('SKIP'  # idk maybe needed probably not
            'SKIP'
            'SKIP')

package() {
    # main executable
    install -Dm755 "$srcdir/path/to/your/executable" "$pkgdir/usr/bin/chat_interface"
    
    # icon
    install -Dm644 "$srcdir/packaging/linux/icons/liphium.png" "$pkgdir/usr/share/icons/hicolor/256x256/apps/liphium.png"
    
    # .desktop file
    install -Dm644 "$srcdir/path/to/your/com.liphium.Liphium.desktop" "$pkgdir/usr/share/applications/com.liphium.Liphium.desktop"
    # TODO: complete this too tired to do it rn
}

