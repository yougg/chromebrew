require 'package'
require_relative 'libx11'

class Xorg_lib < Package
  description 'A collection of xorg libraries.'
  homepage Libx11.homepage.to_s
  version Libx11.version.to_s
  license Libx11.license.to_s
  compatibility Libx11.compatibility.to_s

  is_fake

  depends_on 'libxtrans'
  depends_on 'libx11'
  depends_on 'libxext'
  depends_on 'libfontenc'
  depends_on 'libxinerama'
  depends_on 'libxdamage'
  depends_on 'libxtst'
  depends_on 'libpciaccess'
  depends_on 'libxkbfile'
  depends_on 'libxshmfence'
  depends_on 'libxi'
  depends_on 'libxcursor'
  depends_on 'libxrender'
  depends_on 'libxfixes'

  # new
  depends_on 'libdmx'
  depends_on 'libfs'
  depends_on 'libice'
  depends_on 'libsm'
  depends_on 'libxaw'
  depends_on 'libxfont2'
  depends_on 'libxft'
  depends_on 'libxmu'
  depends_on 'libxpm'
  depends_on 'libxrandr'
  depends_on 'libxres'
  depends_on 'libxt'
  depends_on 'libxv'
  depends_on 'libxvmc'
  depends_on 'libxxf86dga'
  depends_on 'libxxf86vm'
  depends_on 'libxcomposite'
  depends_on 'libxss'
end
