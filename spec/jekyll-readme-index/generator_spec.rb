describe JekyllReadmeIndex::Generator do
  let(:site) { fixture_site(fixture) }
  let(:generator) { described_class.new(site) }
  let(:page) { generator.send(:page) }
  let(:readme) { generator.send(:readme) }
  let(:index?) { generator.send(:index?) }

  before(:each) do
    site.reset
    site.read
  end

  context "with a readme and no index" do
    let(:fixture) { "readme-no-index" }

    it "knows there's a readme" do
      expect(readme).to_not be_nil
      expect(readme.class).to eql(Jekyll::StaticFile)
      expect(readme.relative_path).to eql("/README.md")
    end

    it "knows there's no index" do
      expect(index?).to eql(false)
    end

    it "builds the index page" do
      expect(page.class).to eql(Jekyll::Page)
      expect(page.content).to eql("# Jekyll Readme Index\n")
      expect(page.url).to eql("/")
    end

    it "creates the index page" do
      generator.generate(site)
      expect(site.pages.map(&:name)).to include("README.md")
      expect(site.pages.map(&:url)).to include("/")
    end

    context "building" do
      before { site.process }
      let(:path) { File.join(site.dest, "index.html") }
      let(:content) { File.read(path) }

      it "writes the index" do
        expect(path).to be_an_existing_file
      end

      it "renders the markdown to HTML" do
        expected = "<h1 id=\"jekyll-readme-index\">Jekyll Readme Index</h1>\n"
        expect(content).to eql(expected)
      end
    end
  end

  context "with a readme and an index" do
    let(:fixture) { "readme-and-index" }

    it "knows there's a readme" do
      expect(readme).to_not be_nil
      expect(readme.class).to eql(Jekyll::StaticFile)
      expect(readme.relative_path).to eql("/readme.markdown")
    end

    it "knows there's an index" do
      expect(index?).to eql(true)
    end

    it "doesn't overwrite the index" do
      generator.generate(site)
      expect(site.pages.map(&:name)).to_not include("README.md")
    end

    context "building" do
      before { site.process }
      let(:path) { File.join(site.dest, "index.html") }
      let(:content) { File.read(path) }

      it "writes the index" do
        expect(path).to be_an_existing_file
      end

      it "renders the markdown to HTML" do
        expected = "<h1 id=\"index\">Index</h1>\n"
        expect(content).to eql(expected)
      end
    end
  end

  context "with a readme and a static HTML index" do
    let(:fixture) { "readme-and-html-index" }

    it "knows there's an index" do
      expect(index?).to eql(true)
    end

    it "doesn't overwrite the index" do
      generator.generate(site)
      expect(site.pages.map(&:name)).to_not include("README.md")
    end

    context "building" do
      before { site.process }
      let(:path) { File.join(site.dest, "index.html") }
      let(:content) { File.read(path) }

      it "writes the index" do
        expect(path).to be_an_existing_file
      end

      it "renders the index as the index" do
        expected = "<h1 id=\"index\">Index</h1>\n"
        expect(content).to eql(expected)
      end
    end
  end

  context "with a readme and a HTML index page" do
    let(:fixture) { "readme-and-html-page-index" }

    it "knows there's an index" do
      expect(index?).to eql(true)
    end

    it "doesn't overwrite the index" do
      generator.generate(site)
      expect(site.pages.map(&:name)).to_not include("README.md")
    end

    context "building" do
      before { site.process }
      let(:path) { File.join(site.dest, "index.html") }
      let(:content) { File.read(path) }

      it "writes the index" do
        expect(path).to be_an_existing_file
      end

      it "renders the index as the index" do
        expected = "<h1 id=\"index\">Index</h1>\n"
        expect(content).to eql(expected)
      end
    end
  end

  context "with a readme and an explicit permalink index" do
    let(:fixture) { "readme-and-index-permalink" }

    it "knows there's an index" do
      expect(index?).to eql(true)
    end

    it "doesn't overwrite the index" do
      generator.generate(site)
      expect(site.pages.map(&:name)).to_not include("README.md")
    end

    context "building" do
      before { site.process }
      let(:path) { File.join(site.dest, "index.html") }
      let(:content) { File.read(path) }

      it "writes the index" do
        expect(path).to be_an_existing_file
      end

      it "renders the index as the index" do
        expected = "<h1 id=\"index\">Index</h1>\n"
        expect(content).to eql(expected)
      end
    end
  end

  context "with no readme or index" do
    let(:fixture) { "no-readme-no-index" }

    it "knows there's no readme" do
      expect(readme).to be_nil
    end

    it "knows there's an index" do
      expect(index?).to eql(false)
    end

    context "building" do
      before { site.process }
      let(:path) { File.join(site.dest, "index.html") }

      it "doesn't write an index" do
        expect(path).to_not be_an_existing_file
      end
    end
  end

  context "with an index and no readme" do
    let(:fixture) { "index-no-readme" }

    it "knows there's no readme" do
      expect(readme).to be_nil
    end

    it "knows there's an index" do
      expect(index?).to eql(true)
    end

    context "building" do
      before { site.process }
      let(:path) { File.join(site.dest, "index.html") }
      let(:content) { File.read(path) }

      it "writes the index" do
        expect(path).to be_an_existing_file
      end

      it "renders the markdown to HTML" do
        expected = "<h1>Index</h1>\n"
        expect(content).to eql(expected)
      end
    end
  end

  context "with an XML index" do
    let(:fixture) { "xml-index" }

    it "knows there's an index" do
      expect(index?).to eql(true)
    end

    it "doesn't overwrite the index" do
      generator.generate(site)
      expect(site.pages.map(&:name)).to_not include("README.md")
    end

    context "building" do
      before { site.process }
      let(:path) { File.join(site.dest, "index.xml") }
      let(:content) { File.read(path) }

      it "writes the index" do
        expect(path).to be_an_existing_file
      end

      it "renders the index as the index" do
        expected = "<test>\n  XML Index\n</test>\n"
        expect(content).to match(expected)
      end
    end
  end

  context "with an XHTML index" do
    let(:fixture) { "xhtml-index" }

    it "knows there's an index" do
      expect(index?).to eql(true)
    end

    it "doesn't overwrite the index" do
      generator.generate(site)
      expect(site.pages.map(&:name)).to_not include("README.md")
    end

    context "building" do
      before { site.process }
      let(:path) { File.join(site.dest, "index.xhtml") }
      let(:content) { File.read(path) }

      it "writes the index" do
        expect(path).to be_an_existing_file
      end

      it "renders the index as the index" do
        expected = "<h1 id=\"xhtml-index\">XHTML Index</h1>\n"
        expect(content).to eql(expected)
      end
    end
  end
end
