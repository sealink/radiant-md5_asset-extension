module RadiusSpecHelper
  class Rails
    def self.root
      "#{File.dirname(__FILE__)}"
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end
  module ClassMethods
    def desc(desc)
      @last_desc = desc
    end

    def tag(name, &block)
      @tags ||= []
      @tags << [name, @last_desc, block]
      @last_desc = nil
    end

    def tags
      @tags
    end

    def add_to_context(c)
      @tags.each do |tag_def|
        c.define_tag tag_def.first do |tag|
          tag_def.last.call(tag)
        end
      end
      c
    end
  end
end

