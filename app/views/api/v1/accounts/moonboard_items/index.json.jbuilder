json.array! @moonboard_items do |item|
    json.partial! 'api/v1/models/moonboard_item.json.jbuilder', resource: moonboard_item
  end
    