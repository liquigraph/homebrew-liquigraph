class Liquigraph < Formula
  desc "Migration runner for Neo4j"
  homepage "http://www.liquigraph.org"
  url "https://github.com/fbiville/liquigraph/archive/liquigraph-1.0-RC3.tar.gz"
  sha256 "9b616bd8d8798374d316decd7c1ef60882bf81f6627511af4e3c710143882c47"
  head "https://github.com/fbiville/liquigraph.git"

  depends_on "maven" => :build
  depends_on :java => "1.7+"

  def install
    system "mvn", "-q", "clean", "package", "-DskipTests"
    mkdir "binaries"
    system "tar", "xzf", "liquigraph-cli/target/liquigraph-cli-bin.tar.gz", "-C", "binaries"
    mv "binaries/liquigraph-cli/liquigraph.sh", "binaries/liquigraph-cli/liquigraph"
    bin.install "binaries/liquigraph-cli/liquigraph", "binaries/liquigraph-cli/liquigraph-cli.jar"
  end

  test do
    system "liquigraph", "-h"
  end
end
