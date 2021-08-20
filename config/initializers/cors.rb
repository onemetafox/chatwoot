Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(
        '*'
    )
    resource '*', headers: :any,
             methods: %i[delete get head options post put]
  end
end
