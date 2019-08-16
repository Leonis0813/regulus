class Query
  include ActiveModel::Model

  attribute_names = %i[means page per_page]
  attr_accessor(*attribute_names)

  validates :means,
            inclusion: {in: %w[auto manual], message: 'invalid'},
            allow_nil: true
  validates :page, :per_page,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              message: 'invalid',
            }

  def initialize(attributes = {})
    super
    self.page ||= 1
    self.per_page ||= 10
  end

  def attributes
    self.class.attribute_names.map {|name| [name, send(name)] }.to_h
  end
end
