class Page < ActiveRecord::Base

#  versioning(:content) do |version|
#    version.repository = '/Users/amoore/Sites/rails/pages/.git'
#    version.message = lambda { |page| "Change to #{page.permalink}" }
#  end

  def to_param
    permalink
  end

end
