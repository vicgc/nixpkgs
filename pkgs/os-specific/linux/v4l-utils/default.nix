{ stdenv, lib, fetchurl, pkgconfig, perl
, libjpeg, udev
, withUtils ? true
, withGUI ? true, alsaLib, libX11, qtbase, libGLU
}:

# See libv4l in all-packages.nix for the libs only (overrides alsa, libX11 & QT)

stdenv.mkDerivation rec {
  name = "v4l-utils-${version}";
  version = "1.14.2";

  src = fetchurl {
    url = "http://linuxtv.org/downloads/v4l-utils/${name}.tar.bz2";
    sha256 = "14h6d2p3n4jmxhd8i0p1m5dbwz5vnpb3z88xqd9ghg15n7265fg6";
  };

  outputs = [ "out" "dev" ];

  configureFlags =
    if withUtils then [
      "--with-udevdir=\${out}/lib/udev"
    ] else [
      "--disable-v4l-utils"
    ];

  postFixup = ''
    # Create symlink for V4l1 compatibility
    ln -s "$dev/include/libv4l1-videodev.h" "$dev/include/videodev.h"
  '';

  nativeBuildInputs = [ pkgconfig perl ];

  buildInputs = [ udev ] ++ lib.optionals (withUtils && withGUI) [ alsaLib libX11 qtbase libGLU ];

  propagatedBuildInputs = [ libjpeg ];

  NIX_CFLAGS_COMPILE = lib.optional (withUtils && withGUI) "-std=c++11";

  postPatch = ''
    patchShebangs .
  '';

  meta = with stdenv.lib; {
    description = "V4L utils and libv4l, provide common image formats regardless of the v4l device";
    homepage = https://linuxtv.org/projects.php;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ codyopel viric ];
    platforms = platforms.linux;
  };
}
