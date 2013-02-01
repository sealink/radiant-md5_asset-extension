require 'radius'
require 'radius_spec_helper'

RSpec::Matchers.define :output do |expected|
  match do |tag|
    tag.parser.parse(tag.content).gsub(/\s/, '') == expected.gsub(/\s/, '')
  end

  failure_message_for_should do |tag|
    "#{tag.parser.parse(tag.content).gsub(/\s/, '').to_s} did not match #{expected.gsub(/\s/, '').to_s}"
  end
end

class SpecTag
  attr_accessor :content
  def self.parser=(parser)
    @@parser = parser
  end

  def self.context=(context)
    @@context = context
    @@parser = nil # so parser is regenerated
  end

  def parser
    @@parser ||= Radius::Parser.new(@@context, :tag_prefix => 'r')
  end

  def initialize(content)
    @content = content
    self
  end
end

def content(content)
  SpecTag.new(content)
end
