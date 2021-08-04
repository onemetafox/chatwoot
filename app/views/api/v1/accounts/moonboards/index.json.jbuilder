json.array! @moonboards do |moonboard|
  json.partial! 'api/v1/models/moonboard.json.jbuilder', resource: moonboard
end
  