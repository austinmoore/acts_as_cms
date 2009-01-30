require 'fileutils'
require 'git'

class Page < ActiveRecord::BaseWithoutTable # < ActiveRecord::Base

  PAGES_PATH = "./app/views/pages/"

  attr_accessor :permalink, :content, :name

  column :permalink, :string
  column :name, :string
  column :content, :text

  validates_presence_of :name, :permalink

  def self.all
    Dir.entries(pages_path).collect { |f|
      f if File.fnmatch?('*.yml', f)
    }.compact.collect { |f|
      page = self.load_page_by_permalink(File.basename(f, '.yml'))
    }
  end

  def self.find_by_permalink(permalink)
    page = Page.new(:permalink => permalink)
    page.new_record? ? nil : page
  end

  def self.load_page_by_permalink(permalink)
    if page_path = File.join(pages_path, permalink + '.yml')
      File.file?(page_path) && File.open(page_path, 'r'){ |f|
        YAML::load(f.read)
      }
    end
  end

  def load_page
    page_path = File.join(PAGES_PATH, self.permalink + ".yml")
    if page_path && File.file?(page_path)
      File.open(page_path, 'r'){ |f|
        if page = YAML::load(f.read)
          self.content = page.content
          self.name = page.name
        end
      }
    end
  end

  def self.pages_path
    PAGES_PATH
  end

  def initialize(attributes = {})
    if attributes
      if permalink = attributes[:permalink]
        self.permalink = permalink
        load_page
      end
      self.content = attributes[:content] if attributes[:content]
      self.name = attributes[:name] if attributes[:name]
    end
  end

  def id
    permalink.hash.abs
  end

  def to_param
    permalink
  end

  def new_record?
    !exists?
  end

  def exists?
    page_path && File.file?(page_path)
  end

  def save
    # todo page exists with that permalink, add to errors

    write_file(page_path, self.to_yaml)

    #      g = git
    #      g.add(page_path)
    #      g.commit("Saving #{permalink}")
  end

  def destroy
    File.delete(page_path)
#    g = git
    #    g.remove(page_path)
    #    g.commit("Removing #{permalink}")
    true
  end

  private

  def page_path
    !permalink.nil? && File.join(Page.pages_path, permalink + ".yml")
  end

  def write_file(filepath, content)
    File.open(filepath, 'w') {|f| f.write(content) }
  end

  def git
    g = Git.open(".")
    g.config('user.name', 'User Name')
    g.config('user.email', 'email@email.com')
    g
  end

end
