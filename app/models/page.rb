require 'fileutils'

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
    Page.new(:permalink => permalink) if File.directory?(pages_path + permalink)
  end

  def initialize(attributes = {})
    if attributes
      if permalink = attributes[:permalink]
        self.permalink = permalink
        self.content = read_file("content.text.textile")
        self.name = read_file("name.text.textile")
        self.id = page_dir.hash.abs if File.directory? page_dir
      end
      self.content = attributes[:content] if attributes[:content]
      self.name = attributes[:name] if attributes[:name]
    end
  end

  def to_param
    permalink
  end

  def save
    return false if File.file? page_dir # todo file exists with that name, add to errors

    unless File.exists?(page_dir)
      begin
        Dir.mkdir(page_dir)
      rescue SystemCallError
        return false  # todo directory couldn't be created, add to errors
      end
    end

    Dir.open(page_dir) do |dir|
      File.open(File.join(dir.path, "content.text.textile"), 'w') {|f| f.write(content) }
      File.open(File.join(dir.path, "name.text.textile"), 'w') {|f| f.write(name) }
    end
  end

  def destroy
    FileUtils.remove_dir(page_dir) if File.directory? page_dir
  end

  private

  def self.pages_path
    "./app/views/pages/"
  end

  def page_dir
    @page_dir ||= File.join(Page.pages_path, permalink)
  end

  def read_file(basename)
    filepath = File.join(page_dir, basename)
    s = ''
    File.open(filepath, 'r') do |f|
      s = f.read
    end
    s
  end

end
