class Organisation
  include Mongoid::Document

  field :slug, type: String
  field :title, type: String
end
