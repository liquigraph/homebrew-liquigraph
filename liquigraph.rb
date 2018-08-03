class Liquigraph < Formula
  desc "Migration runner for Neo4j"
  homepage "http://www.liquigraph.org"
  url "https://github.com/liquigraph/liquigraph/archive/liquigraph-3.0.3.tar.gz"
  sha256 "11ec760e27d3c6d8addcae17096aa731f7f1b2b796e90e6e4aea4bff4b98da4f"
  head "https://github.com/liquigraph/liquigraph.git"

  depends_on "maven" => :build
  depends_on :java => "1.8"

  def install
    cmd = Language::Java.java_home_cmd("1.8")
    ENV["JAVA_HOME"] = Utils.popen_read(cmd).chomp
    system "mvn", "-B", "-q", "-am", "-pl", "liquigraph-cli", "clean", "package", "-DskipTests"
    (buildpath/"binaries").mkpath
    system "tar", "xzf", "liquigraph-cli/target/liquigraph-cli-bin.tar.gz", "-C", "binaries"
    libexec.install "binaries/liquigraph-cli/liquigraph.sh"
    libexec.install "binaries/liquigraph-cli/liquigraph-cli.jar"
    (bin/"liquigraph").write_env_script libexec/"liquigraph.sh", Language::Java.java_home_env("1.8")
  end

  test do
    failing_hostname = "verrryyyy_unlikely_host"
    changelog = testpath/"changelog"
    changelog.write <<~EOS
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

    jdbc = "jdbc:neo4j:http://#{failing_hostname}:7474/"
    output = shell_output("#{bin}/liquigraph -c #{changelog.realpath} -g #{jdbc} 2>&1", 1)
    assert_match "UnknownHostException: #{failing_hostname}", output
  end
end
