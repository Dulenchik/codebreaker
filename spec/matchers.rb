RSpec::Matchers.define :have_items_in_range do |range|
  match do |array|
    result = true
    array.each { |item| result &= range.include?(item) }
    result
  end
end