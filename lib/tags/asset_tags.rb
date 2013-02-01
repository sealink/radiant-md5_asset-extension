require 'digest/md5'

module AssetTags
  if defined? Radiant
    include Radiant::Taggable
  else
    include RadiusSpecHelper
  end


  desc %{
    It generates javascript tag

    *Usage:*
    <pre><code>
        <r:script src='/javascripts/application.js' />
    </code></pre>

    Sample output <link href='/javascripts/application.js?e3f7a846526886746de5d06d0b00dea5' />
  }

  tag 'javascript' do |tag|
    "<script src=\"#{md5_path(tag.attr['src'])}\"></script>"
  end


  desc %{
    It generates stylesheet link tag

    *Usage:*
    <pre><code>
        <r:stylesheet src='/stylesheets/application.css' />
    </code></pre>

    Sample output <link href='/stylesheets/application.css?e3f7a846526886746de5d06d0b00dea5' rel='stylesheet' type='text/css' />
  }

  tag 'stylesheet' do |tag|
    "<link href=\"#{md5_path(tag.attr['src'])}\" rel=\"stylesheet\" type=\"text/css\" />"
  end

  private

  def self.md5_path(src)
    md5 = Digest::MD5.hexdigest(asset_content(src))
    "#{src}?#{md5}"
  end

  def self.asset_content(src)
    path = "#{Rails.root}/public#{src}"
    File.read(path)
  end
end
