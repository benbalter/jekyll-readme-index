describe JekyllReadmeIndex::Generator do
  let(:overrides) { {} }
  let(:site) { fixture_site(fixture, overrides) }
  let(:readmes) { subject.send(:readmes) }
  let(:dir) { "/" }
  let(:index?) { subject.send(:dir_has_index?, dir) }
  let(:readme) { readmes.find { |r| r.url =~ %r!#{dir}README\..*!i } }
  let(:page) { readme.to_page }
  let(:should_be_index?) { subject.send(:should_be_index?, readme) }
  let(:index_name) { "index.html" }
  let(:index_path) { File.join(site.dest, dir, index_name) }
  let(:index_content) { File.read(index_path) if File.exist?(index_path) }

  subject { described_class.new(site) }

  before(:each) do
    site.reset
    site.read
  end

  context "with a single README" do
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

      it "knows the readme should be the index" do
        expect(should_be_index?).to eql(true)
      end

      it "builds the index page" do
        expect(page.class).to eql(Jekyll::Page)
        expect(page.content).to eql("# Jekyll Readme Index\n")
        expect(page.url).to eql("/")
      end

      it "creates the index page" do
        subject.generate(site)
        expect(site.pages.map(&:name)).to include("README.md")
        expect(site.pages.map(&:url)).to include("/")
      end

      context "building" do
        before { site.process }

        it "writes the index" do
          expect(index_path).to be_an_existing_file
        end

        it "renders the markdown to HTML" do
          expected = "<h1 id=\"jekyll-readme-index\">Jekyll Readme Index</h1>\n"
          expect(index_content).to eql(expected)
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

      it "knows the readme shouldn't be the index" do
        expect(should_be_index?).to eql(false)
      end

      it "doesn't overwrite the index" do
        subject.generate(site)
        expect(site.pages.map(&:name)).to_not include("README.md")
      end

      context "building" do
        before { site.process }

        it "writes the index" do
          expect(index_path).to be_an_existing_file
        end

        it "renders the markdown to HTML" do
          expected = "<h1 id=\"index\">Index</h1>\n"
          expect(index_content).to eql(expected)
        end
      end
    end

    context "with a readme and a static HTML index" do
      let(:fixture) { "readme-and-html-index" }

      it "knows there's an index" do
        expect(index?).to eql(true)
      end

      it "knows the readme shouldn't be the index" do
        expect(should_be_index?).to eql(false)
      end

      it "doesn't overwrite the index" do
        subject.generate(site)
        expect(site.pages.map(&:name)).to_not include("README.md")
      end

      context "building" do
        before { site.process }

        it "writes the index" do
          expect(index_path).to be_an_existing_file
        end

        it "renders the index as the index" do
          expected = "<h1 id=\"index\">Index</h1>\n"
          expect(index_content).to eql(expected)
        end
      end
    end

    context "with a readme and a HTML index page" do
      let(:fixture) { "readme-and-html-page-index" }

      it "knows there's an index" do
        expect(index?).to eql(true)
      end

      it "knows the readme shouldn't be the index" do
        expect(should_be_index?).to eql(false)
      end

      it "doesn't overwrite the index" do
        subject.generate(site)
        expect(site.pages.map(&:name)).to_not include("README.md")
      end

      context "building" do
        before { site.process }

        it "writes the index" do
          expect(index_path).to be_an_existing_file
        end

        it "renders the index as the index" do
          expected = "<h1 id=\"index\">Index</h1>\n"
          expect(index_content).to eql(expected)
        end
      end
    end

    context "with a readme and an explicit permalink index" do
      let(:fixture) { "readme-and-index-permalink" }

      it "knows there's an index" do
        expect(index?).to eql(true)
      end

      it "knows the readme shouldn't be the index" do
        expect(should_be_index?).to eql(false)
      end

      it "doesn't overwrite the index" do
        subject.generate(site)
        expect(site.pages.map(&:name)).to_not include("README.md")
      end

      context "building" do
        before { site.process }

        it "writes the index" do
          expect(index_path).to be_an_existing_file
        end

        it "renders the index as the index" do
          expected = "<h1 id=\"index\">Index</h1>\n"
          expect(index_content).to eql(expected)
        end
      end
    end

    context "with no readme or index" do
      let(:fixture) { "no-readme-no-index" }

      it "knows there's no readme" do
        expect(readme).to be_nil
      end

      it "doesn't err out on should_be_index?" do
        expect(should_be_index?).to eql(false)
      end

      it "knows there's an index" do
        expect(index?).to eql(false)
      end

      context "building" do
        before { site.process }

        it "doesn't write an index" do
          expect(index_path).to_not be_an_existing_file
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

      it "doesn't err out on should_be_index?" do
        expect(should_be_index?).to eql(false)
      end

      context "building" do
        before { site.process }

        it "writes the index" do
          expect(index_path).to be_an_existing_file
        end

        it "renders the markdown to HTML" do
          expected = "<h1>Index</h1>\n"
          expect(index_content).to eql(expected)
        end
      end
    end

    context "with an XML index" do
      let(:fixture) { "xml-index" }

      it "knows there's an index" do
        expect(index?).to eql(true)
      end

      it "knows the readme shouldn't be the index" do
        expect(should_be_index?).to eql(false)
      end

      it "doesn't overwrite the index" do
        subject.generate(site)
        expect(site.pages.map(&:name)).to_not include("README.md")
      end

      context "building" do
        before { site.process }
        let(:index_name) { "index.xml" }

        it "writes the index" do
          expect(index_path).to be_an_existing_file
        end

        it "renders the index as the index" do
          expected = "<test>\n  XML Index\n</test>\n"
          expect(index_content).to match(expected)
        end
      end
    end

    context "with an XHTML index" do
      let(:fixture) { "xhtml-index" }

      it "knows there's an index" do
        expect(index?).to eql(true)
      end

      it "knows the readme shouldn't be the index" do
        expect(should_be_index?).to eql(false)
      end

      it "doesn't overwrite the index" do
        subject.generate(site)
        expect(site.pages.map(&:name)).to_not include("README.md")
      end

      context "building" do
        before { site.process }
        let(:index_name) { "index.xhtml" }

        it "writes the index" do
          expect(index_path).to be_an_existing_file
        end

        it "renders the index as the index" do
          expected = "<h1 id=\"xhtml-index\">XHTML Index</h1>\n"
          expect(index_content).to eql(expected)
        end
      end
    end
  end

  context "with multiple readmes" do
    let(:fixture) { "readme-and-nested-readme" }

    context "the root directory" do
      let(:dir) { "/" }

      it "knows there's a readme" do
        expect(readme).to_not be_nil
        expect(readme.class).to eql(Jekyll::StaticFile)
        expect(readme.relative_path).to eql("/README.md")
      end

      it "knows there's no index" do
        expect(index?).to eql(false)
      end

      it "knows the readme should be the index" do
        expect(should_be_index?).to eql(true)
      end

      it "builds the index page" do
        expect(page.class).to eql(Jekyll::Page)
        expect(page.content).to eql("# Top-level Readme Index\n")
        expect(page.url).to eql("/")
      end

      it "creates the index page" do
        subject.generate(site)
        expect(site.pages.map(&:name)).to include("README.md")
        expect(site.pages.map(&:url)).to include("/")
      end

      context "building" do
        before { site.process }

        it "writes the index" do
          expect(index_path).to be_an_existing_file
        end

        it "renders the markdown to HTML" do
          expected = "<h1 id=\"top-level-readme-index\">Top-level Readme Index</h1>\n"
          expect(index_content).to eql(expected)
        end
      end
    end

    context "a subfolder with a readme" do
      let(:dir) { "/with_readme/" }

      it "knows there's a readme" do
        expect(readme).to_not be_nil
        expect(readme.class).to eql(Jekyll::StaticFile)
        expect(readme.relative_path).to eql("#{dir}README.md")
      end

      it "knows there's no index" do
        expect(index?).to eql(false)
      end

      it "knows the readme should be the index" do
        expect(should_be_index?).to eql(true)
      end

      it "builds the index page" do
        expect(page.class).to eql(Jekyll::Page)
        expect(page.content).to eql("# Second-level Readme\n")
        expect(page.url).to eql(dir)
      end

      it "creates the index page" do
        subject.generate(site)
        expect(site.pages.map(&:name)).to include("README.md")
        expect(site.pages.map(&:url)).to include(dir)
      end

      context "building" do
        before { site.process }

        it "writes the index" do
          expect(index_path).to be_an_existing_file
        end

        it "renders the markdown to HTML" do
          expected = "<h1 id=\"second-level-readme\">Second-level Readme</h1>\n"
          expect(index_content).to eql(expected)
        end
      end
    end

    context "a subfolder with a readme and an index" do
      let(:dir) { "/with_readme_and_index/" }

      it "knows there's a readme" do
        expect(readme).to_not be_nil
        expect(readme.class).to eql(Jekyll::StaticFile)
        expect(readme.relative_path).to eql("#{dir}README.md")
      end

      it "knows there's an index" do
        expect(index?).to eql(true)
      end

      it "knows the readme shouldn't be the index" do
        expect(should_be_index?).to eql(false)
      end

      context "building" do
        before { site.process }

        it "writes the index" do
          expect(index_path).to be_an_existing_file
        end

        it "renders the index as the index" do
          expected = "<h1 id=\"index2\">Second-level Index</h1>\n"
          expect(index_content).to eql(expected)
        end
      end
    end

    context "a subfolder without a readme" do
      let(:dir) { "/without_readme" }

      it "knows there's no readme" do
        expect(readme).to be_nil
      end

      it "knows the readme shouldn't be the index" do
        expect(should_be_index?).to eql(false)
      end

      context "building" do
        before { site.process }

        it "doesn't write the index" do
          expect(index_path).to_not be_an_existing_file
        end
      end
    end
  end

  context "cleanup" do
    let(:overrides) { { "readme_index" => { "remove_originals" => true } } }

    context "with a single README" do
      context "with a readme and no index" do
        let(:fixture) { "readme-no-index" }

        it "creates the index page" do
          subject.generate(site)
          expect(site.pages.map(&:name)).to include("README.md")
          expect(site.pages.map(&:url)).to include("/")
        end

        it "removes the readme file" do
          subject.generate(site)
          expect(site.static_files.map(&:relative_path)).to_not include("/README.md")
        end
      end

      context "with a readme and an index" do
        let(:fixture) { "readme-and-index" }

        it "doesn't overwrite the index" do
          subject.generate(site)
          expect(site.pages.map(&:name)).to_not include("readme.markdown")
        end

        it "doesn't remove the readme file" do
          subject.generate(site)
          expect(site.static_files.map(&:relative_path)).to include("/readme.markdown")
        end
      end

      context "with a readme and a static HTML index" do
        let(:fixture) { "readme-and-html-index" }

        it "doesn't overwrite the index" do
          subject.generate(site)
          expect(site.pages.map(&:name)).to_not include("readme.markdown")
        end

        it "doesn't remove the readme file" do
          subject.generate(site)
          expect(site.static_files.map(&:relative_path)).to include("/readme.markdown")
        end
      end

      context "with a readme and a HTML index page" do
        let(:fixture) { "readme-and-html-page-index" }

        it "doesn't overwrite the index" do
          subject.generate(site)
          expect(site.pages.map(&:name)).to_not include("readme.markdown")
        end

        it "doesn't remove the readme file" do
          subject.generate(site)
          expect(site.static_files.map(&:relative_path)).to include("/readme.markdown")
        end
      end

      context "with a readme and an explicit permalink index" do
        let(:fixture) { "readme-and-index-permalink" }

        it "doesn't overwrite the index" do
          subject.generate(site)
          expect(site.pages.map(&:name)).to_not include("readme.markdown")
        end

        it "doesn't remove the readme file" do
          subject.generate(site)
          expect(site.static_files.map(&:relative_path)).to include("/readme.markdown")
        end
      end
    end

    context "with multiple readmes" do
      let(:fixture) { "readme-and-nested-readme" }

      context "the root directory" do
        let(:dir) { "/" }

        it "creates the index page" do
          subject.generate(site)
          expect(site.pages.map(&:name)).to include("README.md")
          expect(site.pages.map(&:url)).to include("/")
        end

        it "does remove the root readme file" do
          subject.generate(site)
          readme = "/readme.markdown"
          expect(site.static_files.map(&:relative_path)).to_not include(readme)
        end
      end

      context "a subfolder with a readme" do
        let(:dir) { "/with_readme/" }

        it "creates the index page" do
          subject.generate(site)
          expect(site.pages.map(&:name)).to include("README.md")
          expect(site.pages.map(&:url)).to include(dir)
        end

        it "does remove the subfolder readme file" do
          subject.generate(site)
          readme = "/with_readme/readme.markdown"
          expect(site.static_files.map(&:relative_path)).to_not include(readme)
        end
      end
    end
  end

  context "when disabled" do
    let(:fixture) { "readme-no-index" }
    let(:overrides) { { "readme_index" => { "enabled" => false } } }

    it "doesn't create the index page" do
      subject.generate(site)
      expect(site.pages.map(&:name)).to_not include("README.md")
      expect(site.pages.map(&:url)).to_not include("/")
    end
  end

  context "when explicitly enabled" do
    let(:fixture) { "readme-no-index" }
    let(:overrides) { { "readme_index" => { "enabled" => true } } }

    it "does create the index page" do
      subject.generate(site)
      expect(site.pages.map(&:name)).to include("README.md")
      expect(site.pages.map(&:url)).to include("/")
    end
  end
end
