require "language/go"
require "yaml"

class Siegfried < Formula
  desc "Signature-based file identification tool"
  homepage "https://www.itforarchivists.com/siegfried"
  url "https://github.com/richardlehane/siegfried/archive/v1.7.10.tar.gz"
  sha256 "abe60898993dc3bb0593550e5951ecab047da965c9178967cd486e26bb6e927f"
  head "https://github.com/richardlehane/siegfried.git", :branch => "develop"

  depends_on "go" => :build

  def install
    # Avoid installing signature files into the user's home directory;
    # install them into share instead.
    inreplace "pkg/config/brew.go", "/usr/share/siegfried", share/"siegfried"

    mkdir_p buildpath/"src/github.com/richardlehane"
    ln_s buildpath, buildpath/"src/github.com/richardlehane/siegfried"

    ENV["GOPATH"] = buildpath

    system "go", "build", "-tags", "brew",
                 "github.com/richardlehane/siegfried/cmd/sf"
    system "go", "build", "-tags", "brew",
                 "github.com/richardlehane/siegfried/cmd/roy"

    bin.install "sf", "roy"
    (share/"siegfried").install Dir["src/github.com/richardlehane/siegfried/cmd/roy/data/*"]
  end

  test do
    results = YAML.load_documents `"#{bin}/sf" "#{test_fixtures("test.jpg")}"`
    assert_equal version.to_s, results[0]["siegfried"]
    assert_equal "fmt/43", results[1]["matches"][0]["puid"]
  end
end
