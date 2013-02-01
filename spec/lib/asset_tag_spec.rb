require 'spec_helper'
require 'tags/asset_tags'

describe AssetTags do
  before do
    SpecTag.context = AssetTags.add_to_context(Radius::Context.new)
  end

  describe '<r:javascript>' do
    # d73b04b0e696b0945283defa3eee4538 is md5 of "helloworld" which is in the js file
    it 'should display the correct tag and md5' do
      content('<r:javascript src="/javascripts/application.js" />').
        should output '<script src="/javascripts/application.js?d73b04b0e696b0945283defa3eee4538"></script>'
    end
  end

  describe '<r:stylesheet>' do
    # d73b04b0e696b0945283defa3eee4538 is md5 of "helloworld" which is in the css file
    it 'should display the correct tag and md5' do
      content('<r:stylesheet src="/stylesheets/application.css" />').
        should output '<link href="/stylesheets/application.css?d73b04b0e696b0945283defa3eee4538" rel="stylesheet" type="text/css" />'
    end
  end
end
