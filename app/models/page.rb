require 'fileutils'
require 'git'

class Page < ActiveRecord::BaseWithoutTable # < ActiveRecord::Base

  attr_accessor :permalink, :content, :name, :id

  column :permalink, :string
  column :name, :string
  column :content, :text

  validates_presence_of :name, :permalink

  #  versioning(:content) do |version|
  #    version.repository = '/Users/amoore/Sites/rails/pages/.git'
  #    version.message = lambda { |page| "Change to #{page.permalink}" }
  #  end

  def self.all
    Dir.entries(pages_path).collect { |f|
      dir = File.join(pages_path, f) unless f == '.' || f == '..'
      dir if dir && File.directory?(dir)
    }.compact.collect { |dir|
      Page.new(:permalink => File.basename(dir))
    }
  end

  def self.find_by_permalink(permalink)
    page = Page.new(:permalink => permalink)
    page.new_record? ? nil : page
  end

  def initialize(attributes = {})
    if attributes
      if permalink = attributes[:permalink]
        self.permalink = permalink
        self.content = read_file("content.text.textile")
        self.name = read_file("name.text.textile")
        self.id = page_path.hash.abs if File.directory? page_path
      end
      self.content = attributes[:content] if attributes[:content]
      self.name = attributes[:name] if attributes[:name]
    end
  end

  def to_param
    permalink
  end

  def new_record?
    !exists?
  end

  def exists?
    page_path && File.directory?(page_path)
  end

  def save
    return false if File.file? page_path # todo file exists with that name, add to errors

    unless File.exists?(page_path)
      begin
        Dir.mkdir(page_path)
        
      rescue SystemCallError
        return false  # todo directory couldn't be created, add to errors
      end
    end

    Dir.open(page_path) do |dir|
      write_file(File.join(dir.path, "content.text.textile"), content)
      write_file(File.join(dir.path, "name.text.textile"), name)

      g = git
      g.add(page_path)
      g.commit("Saving #{permalink}")
      true
    end
  end

  def destroy
    destroy_dir
    g = git
    g.remove(page_path)
    g.commit("Removing #{permalink}")
    true
  end
  
  private

  def self.pages_path
    "./app/views/pages/"
  end

  def page_path
    @page_dir ||= !permalink.nil? && File.join(Page.pages_path, permalink)
  end

  def write_file(filepath, content)
    File.open(filepath, 'w') {|f| f.write(content) }
  end

  def read_file(basename)
    filepath = File.join(page_path, basename)
    s = ''
    File.exists?(filepath) && File.open(filepath, 'r') do |f|
      s = f.read
    end
    s
  end

  def destroy_dir
    FileUtils.remove_dir(page_path) if File.directory? page_path
  end

  def git
    g = Git.open(".")
    g.config('user.name', 'User Name')
    g.config('user.email', 'email@email.com')
    g
  end

end
