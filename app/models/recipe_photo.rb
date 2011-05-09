class RecipePhoto < ActiveRecord::Base
  belongs_to :recipe
  has_attached_file :photo,
                    :styles => { :original => "640x640",
                                 :thumb => "100x100" },
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :path => ":attachment/:id/:style.:extension",
                    :bucket => "gobbledybook"

  validates_attachment_content_type :photo, :content_type => ['image/gif',
    'image/jpeg', 'image/pjpeg', 'image/png', 'image/x-png']

  # This turns out to be they way to turn on the 'whiny' property which reports
  # errors if there were any errors creating thumbnail.  We use these errors
  # to determine whether to continue the upload.
end
