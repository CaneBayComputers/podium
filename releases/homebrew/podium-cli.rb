class PodiumCli < Formula
  desc "Professional PHP development platform with Docker - One command creates Laravel/WordPress projects"
  homepage "https://github.com/CaneBayComputers/podium-cli"
  url "https://github.com/CaneBayComputers/podium-cli/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "f8721c2a289e1005e30328dc083f9fd22f1dd7c5f9fbfc5ebcbf8d9c559389b9"
  license "MIT"
  version "1.1.0"

  depends_on "docker" => :recommended
  depends_on "git"
  depends_on "curl"
  depends_on "jq"

  def install
    # Install all source files to the prefix
    prefix.install Dir["*"]
    
    # Create symlink for the main podium command
    bin.install_symlink prefix/"src/podium"
    
    # Make scripts executable
    chmod 0755, prefix/"src/scripts/install.sh"
    chmod 0755, prefix/"src/podium"
  end

  def post_install
    # Run the installation script in GUI mode (non-interactive)
    system "#{prefix}/src/scripts/install.sh", "--gui-mode", "--skip-aws"
    
    ohai "Podium CLI installed successfully!"
    puts ""
    puts "🎭 Get started with: podium new"
    puts "📖 Documentation: https://github.com/CaneBayComputers/podium-cli"
    puts ""
  end

  test do
    # Test that the podium command exists and shows help
    assert_match "Professional PHP Development Platform", shell_output("#{bin}/podium help")
  end

  def caveats
    <<~EOS
      🐳 Docker is required for Podium to work.
      
      If you don't have Docker installed:
        brew install --cask docker
      
      Make sure Docker is running before using Podium.
      
      🚀 Create your first project:
        podium new my-awesome-project
      
      📱 Access projects from any device on your network!
    EOS
  end
end
