module Morph
  class Language
    LANGUAGES_SUPPORTED = [:ruby, :php, :python, :perl]

    WEBSITES = {
      ruby: "https://www.ruby-lang.org/en/",
      php: "http://www.php.net/",
      python: "https://www.python.org/",
      perl: "http://www.perl.org/"
    }

    HUMAN = {ruby: "Ruby", php: "PHP", python: "Python", perl: "Perl" }

    FILE_EXTENSIONS = {ruby: "rb", php: "php", python: "py", perl: "pl"}

    attr_reader :key

    def initialize(key)
      @key = key
    end

    # Find the language of the code in the given directory
    def self.language(repo_path)
      LANGUAGES_SUPPORTED.find do |language|
        File.exists?(File.join(repo_path, language_to_scraper_filename(language)))
      end
    end

    def self.language2(repo_path)
      Language.new(language)
    end

    def self.languages_supported2
      LANGUAGES_SUPPORTED.map{|l| Language.new(l)}
    end

    def self.main_scraper_filename(repo_path)
      language2(repo_path).scraper_filename
    end

    def human
      t = HUMAN[key]
      raise "Unsupported language" if t.nil?
      t
    end

    def website
      WEBSITES[key]
    end

    def image_path
      "languages/#{key}.png"
    end

    def scraper_filename
      Language.language_to_scraper_filename(@key)
    end

    def scraper_command
      Language.scraper_command(@key)
    end

    def supported?
      Language.language_supported?(@key)
    end

    def default_scraper
      Language.default_scraper(@key)
    end

    private

    # Name of the binary for running scripts of a particular language
    def self.binary_name(language)
      case language
      when :ruby
        # Run a special script of ours before anything else which switches off
        # buffering on stdout and stderr
        "ruby -r/usr/local/lib/prerun.rb"
      when :php
        "php"
      when :python
        # -u turns off buffering for stdout and stderr
        "python -u"
      when :perl
        "perl"
      end
    end

    def self.language_to_scraper_filename(language)
      "scraper.#{FILE_EXTENSIONS[language]}" if language
    end

    def self.scraper_command(language)
      "#{binary_name(language)} /repo/#{language_to_scraper_filename(language)}"
    end

    def self.language_supported?(language)
      LANGUAGES_SUPPORTED.include?(language)
    end

    def self.default_scraper(language)
      if language == :ruby
        <<-EOF
# This is a template for a Ruby scraper on Morph (https://morph.io)
# including some code snippets below that you should find helpful

# require 'scraperwiki'
# require 'mechanize'
#
# agent = Mechanize.new
#
# # Read in a page
# page = agent.get("http://foo.com")
#
# # Find somehing on the page using css selectors
# p page.at('div.content')
#
# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})
#
# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries. You can use whatever gems are installed
# on Morph for Ruby (https://github.com/openaustralia/morph-docker-ruby/blob/master/Gemfile) and all that matters
# is that your final data is written to an Sqlite database called data.sqlite in the current working directory which
# has at least a table called data.
        EOF
      elsif language == :php
        <<-EOF
<?
// This is a template for a PHP scraper on Morph (https://morph.io)
// including some code snippets below that you should find helpful

// require 'scraperwiki.php';
// require 'scraperwiki/simple_html_dom.php';
//
// // Read in a page
// $html = scraperwiki::scrape("http://foo.com");
//
// // Find something on the page using css selectors
// $dom = new simple_html_dom();
// $dom->load($html);
// print_r($dom->find("table.list"));
//
// // Write out to the sqlite database using scraperwiki library
// scraperwiki::save_sqlite(array('name'), array('name' => 'susan', 'occupation' => 'software developer'));
//
// // An arbitrary query against the database
// scraperwiki::select("* from data where 'name'='peter'")

// You don't have to do things with the ScraperWiki library. You can use whatever is installed
// on Morph for PHP (See https://github.com/openaustralia/morph-docker-php) and all that matters
// is that your final data is written to an Sqlite database called data.sqlite in the current working directory which
// has at least a table called data.
?>
        EOF
      elsif language == :python
        <<-EOF
# This is a template for a Python scraper on Morph (https://morph.io)
# including some code snippets below that you should find helpful

# import scraperwiki
# import lxml.html
#
# # Read in a page
# html = scraperwiki.scrape("http://foo.com")
#
# # Find something on the page using css selectors
# root = lxml.html.fromstring(html)
# root.cssselect("div[align='left']")
#
# # Write out to the sqlite database using scraperwiki library
# scraperwiki.sqlite.save(unique_keys=['name'], data={"name": "susan", "occupation": "software developer"})
#
# # An arbitrary query against the database
# scraperwiki.sql.select("* from data where 'name'='peter'")

# You don't have to do things with the ScraperWiki and lxml libraries. You can use whatever libraries are installed
# on Morph for Python (https://github.com/openaustralia/morph-docker-python/blob/master/pip_requirements.txt) and all that matters
# is that your final data is written to an Sqlite database called data.sqlite in the current working directory which
# has at least a table called data.
        EOF
      elsif language == :perl
        <<-EOF
# This is a template for a Perl scraper on Morph (https://morph.io)
# including some code snippets below that you should find helpful

# use LWP::Simple;
# use HTML::TreeBuilder;
# use Database::DumpTruck;

# use strict;
# use warnings;

# # Read out and parse a web page
# my $tb = HTML::TreeBuilder->new_from_content(get('http://example.com/'));

# # Look for <tr>s of <table id="hello">
# my @rows = $tb->look_down(
#     _tag => 'tr',
#     sub { shift->parent->attr('id') eq 'hello' }
# );

# # Open a database handle
# my $dt = Database::DumpTruck->new({dbname => 'data.sqlite', table => 'data'});
#
# # Insert content of <td id="name"> and <td id="age"> into the database
# $dt->insert([map {{
#     Name => $_->look_down(_tag => 'td', id => 'name')->content,
#     Age => $_->look_down(_tag => 'td', id => 'age')->content,
# }} @rows]);

# You don't have to do things with the HTML::TreeBuilder and Database::DumpTruck
# libraries. You can use whatever libraries are installed on Morph for Perl
# (https://github.com/openaustralia/morph-docker-perl/blob/master/Dockerfile)
# and all that matters is that your final data is written to an Sqlite
# database called data.sqlite in the current working directory which has at
# least a table called data.
        EOF
      else
        raise "Not yet supported"
      end
    end
  end
end
