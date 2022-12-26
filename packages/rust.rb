require 'package'

class Rust < Package
  description 'Rust is a systems programming language that runs blazingly fast, prevents segfaults, and guarantees thread safety.'
  homepage 'https://www.rust-lang.org/'
  @_ver = '1.66.0'
  version @_ver
  license 'Apache-2.0 and MIT'
  compatibility 'all'
  source_url 'https://github.com/rust-lang/rustup.git'
  git_hashtag '1.25.1'

  binary_url({
    aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/rust/1.66.0_armv7l/rust-1.66.0-chromeos-armv7l.tar.zst',
     armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/rust/1.66.0_armv7l/rust-1.66.0-chromeos-armv7l.tar.zst',
       i686: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/rust/1.66.0_i686/rust-1.66.0-chromeos-i686.tar.zst',
     x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/rust/1.66.0_x86_64/rust-1.66.0-chromeos-x86_64.tar.zst'
  })
  binary_sha256({
    aarch64: '553439100777568385d6ea7368076cc8255f108dcb5cb0df51619cf68d6914c9',
     armv7l: '553439100777568385d6ea7368076cc8255f108dcb5cb0df51619cf68d6914c9',
       i686: 'b878f22141bc0c3b13682bf1c6e71d2bb2fb90e6eb7b500edeb94e686fe11119',
     x86_64: '54ffc6fc69f8af863aef3db15c74997a272c6754acef5ee1f57bf3bbaefd8af7'
  })

  depends_on 'gcc' # R
  depends_on 'glibc' # R
  depends_on 'zlibpkg' # R

  def self.install
    ENV['RUST_BACKTRACE'] = 'full'
    ENV['CARGO_HOME'] = "#{CREW_DEST_PREFIX}/share/cargo"
    ENV['RUSTUP_HOME'] = "#{CREW_DEST_PREFIX}/share/rustup"
    default_host = ARCH == 'aarch64' || ARCH == 'armv7l' ? 'armv7-unknown-linux-gnueabihf' : "#{ARCH}-unknown-linux-gnu"
    system "sed -i 's,$(mktemp -d 2>/dev/null || ensure mktemp -d -t rustup),#{CREW_PREFIX}/tmp,' rustup-init.sh"
    FileUtils.mkdir_p(CREW_DEST_HOME)
    FileUtils.mkdir_p("#{CREW_DEST_PREFIX}/bin")
    FileUtils.mkdir_p("#{CREW_DEST_PREFIX}/share/cargo")
    FileUtils.mkdir_p("#{CREW_DEST_PREFIX}/share/rustup")
    system "RUSTFLAGS='-Clto=thin' bash ./rustup-init.sh -y --no-modify-path --default-host #{default_host} --default-toolchain #{@_ver} --profile minimal"
    FileUtils.mkdir_p("#{CREW_DEST_PREFIX}/share/bash-completion/completions/")
    FileUtils.install "#{CREW_DEST_PREFIX}/share/rustup/toolchains/#{@_ver}-#{default_host}/etc/bash_completion.d/cargo", "#{CREW_DEST_PREFIX}/share/bash-completion/completions/cargo", mode: 0o644
    FileUtils.rm("#{CREW_DEST_PREFIX}/share/rustup/toolchains/#{@_ver}-#{default_host}/etc/bash_completion.d/cargo")
    FileUtils.touch "#{CREW_DEST_PREFIX}/share/bash-completion/completions/rustup"
    FileUtils.mv("#{CREW_DEST_PREFIX}/share/rustup/toolchains/#{@_ver}-#{default_host}/share/man/",
                 "#{CREW_DEST_PREFIX}/share/")
    FileUtils.rm_rf("#{CREW_DEST_PREFIX}/share/rustup/toolchains/#{@_ver}-#{default_host}/share/doc/")
    FileUtils.ln_sf("#{CREW_PREFIX}/share/cargo", "#{CREW_DEST_HOME}/.cargo")
    FileUtils.ln_sf("#{CREW_PREFIX}/share/rustup", "#{CREW_DEST_HOME}/.rustup")

    FileUtils.mkdir_p "#{CREW_DEST_PREFIX}/etc/env.d/"
    @rustconfigenv = <<~RUSTCONFIGEOF
      # Rustup and cargo configuration
      export CARGO_HOME=#{CREW_PREFIX}/share/cargo
      export RUSTUP_HOME=#{CREW_PREFIX}/share/rustup
    RUSTCONFIGEOF
    File.write("#{CREW_DEST_PREFIX}/etc/env.d/rust", @rustconfigenv)

    FileUtils.mkdir_p "#{CREW_DEST_PREFIX}/etc/bash.d/"
    @rustcompletionenv = <<~RUSTCOMPLETIONEOF
      # Rustup and cargo bash completion
      source #{CREW_PREFIX}/share/bash-completion/completions/cargo
      source #{CREW_PREFIX}/share/bash-completion/completions/rustup
    RUSTCOMPLETIONEOF
    File.write("#{CREW_DEST_PREFIX}/etc/bash.d/rust", @rustcompletionenv)
    system "#{CREW_DEST_PREFIX}/share/cargo/bin/rustup completions bash > #{CREW_DEST_PREFIX}/share/bash-completion/completions/rustup"
    Dir.chdir "#{CREW_DEST_PREFIX}/share/cargo/bin" do
      Dir.children('.').delete_if { |f| f == 'cargo' }.each do |filename|
        FileUtils.ln_sf 'cargo', filename
      end
    end
    Dir.chdir "#{CREW_DEST_PREFIX}/bin" do
      Dir.each_child('../share/cargo/bin') do |f|
        FileUtils.ln_sf "../share/cargo/bin/#{f}", f
      end
    end
  end

  def self.remove
    config_dirs = %W[#{HOME}/.rustup #{CREW_PREFIX}/share/rustup #{HOME}/.cargo #{CREW_PREFIX}/share/cargo]
    print config_dirs.to_s
    print "\nWould you like to remove the config directories above? [y/N] "
    case $stdin.getc
    when 'y', 'Y'
      FileUtils.rm_rf config_dirs
      puts "#{config_dirs} removed.".lightgreen
    else
      puts "#{config_dirs} saved.".lightgreen
    end
  end
end
