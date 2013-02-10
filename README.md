Radiant MD5 Extension
=====================

[![Build Status](https://travis-ci.org/sealink/radiant-md5_asset-extension.png?branch=master)](https://travis-ci.org/sealink/radiant-md5_asset-extension)
[![Build Status](https://gemnasium.com/sealink/radiant-md5_asset-extension.png?travis)](https://gemnasium.com/sealink/radiant-md5_asset-extension)
[![Build Status](https://codeclimate.com/github/sealink/radiant-md5_asset-extension.png)](https://codeclimate.com/github/sealink/radiant-md5_asset-extension)
 
# DESCRIPTION

Provides 2 tags to enable your static javascript/css assets to have a md5 argument on the end for use in caching

# INSTALLATION

Add to your Gemfile:

```ruby
gem 'radiant-md5_asset-extension', github: 'sealink/radiant-md5_asset-extension'
```

# USAGE

```html
<r:javascript src="/javascripts/application.js" />
<r:stylesheet src="/stylesheets/application.css" />
```

This will result in something like:

```html
<script src="/javascripts/application.js?e3f7a846526886746de5d06d0b00dea5"></script>
<link href="/stylesheets/application.css?e3f7a846526886746de5d06d0b00dea5" rel="stylesheet" type="text/css" />
```

# CONTRIBUTING
Fork this project, add your changes and submit a pull request
