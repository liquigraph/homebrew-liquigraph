class Liquigraph < Formula
  desc "Migration runner for Neo4j"
  homepage "http://www.liquigraph.org"
  url "https://github.com/fbiville/liquigraph/archive/liquigraph-1.0-RC3.tar.gz"
  sha256 "9b616bd8d8798374d316decd7c1ef60882bf81f6627511af4e3c710143882c47"
  head "https://github.com/fbiville/liquigraph.git"

  depends_on "maven" => :build
  depends_on :java => "1.7+"

  def install
    ENV.java_cache
    system "mvn", "-q", "clean", "package", "-DskipTests"
    mkdir "binaries"
    system "tar", "xzf", "liquigraph-cli/target/liquigraph-cli-bin.tar.gz", "-C", "binaries"
    libexec.install "binaries/liquigraph-cli/liquigraph.sh" => "liquigraph"
    libexec.install "binaries/liquigraph-cli/liquigraph-cli.jar"
    bin.install_symlink libexec/"liquigraph"
  end

  test do
    failing_hostname = "verrryyyy_unlikely_host"
    changelog = (testpath/"changelog")
    changelog.write <<-EOS.undent
<?xml version="1.0" encoding="UTF-8"?>
<changelog>
    <changeset id="hello-world" author="you">
        <query>CREATE (n:Sentence {text:'Hello monde!'}) RETURN n</query>
    </changeset>
    <changeset id="hello-world-fixed" author="you">
        <query>MATCH (n:Sentence {text:'Hello monde!'}) SET n.text='Hello world!' RETURN n</query>
    </changeset>
</changelog>
EOS
    assert_match(
      /UnknownHostException: #{failing_hostname}/,
      shell_output("#{bin}/liquigraph -c #{changelog.realpath} -g jdbc:neo4j://#{failing_hostname}:7474/ 2>&1", 1)
    )
  end
end
