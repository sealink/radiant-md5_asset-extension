# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'
class Md5AssetExtension < Radiant::Extension
  version "1.0"
  description "This extension provides tags to have a md5 argument on javascript/stylesheet asset urls"
  url ''


  def activate
    # Load the tags into the page
    require 'tags/asset_tags'
    Page.send :include, AssetTags
  end


  def deactivate
  end
end
