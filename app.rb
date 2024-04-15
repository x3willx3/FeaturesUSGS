require 'sinatra'
require 'json'
require 'sqlite3'

# Configuración de la base de datos SQLite3
DB = SQLite3::Database.new('BD_Data.db')
DB.results_as_hash = true

# Método para verificar si las tablas existen en la base de datos
def tablas_existen?
  # Consulta para obtener la lista de tablas en la base de datos
  tablas = DB.execute("SELECT name FROM sqlite_master WHERE type='table';").flatten
  # Verifica si las tablas necesarias existen
  ['features', 'comments'].all? { |tabla| tablas.include?(tabla) }
end

# Método para crear las tablas si no existen
def crear_tablas
  # Script para crear la tabla 'features'
  DB.execute <<-SQL
    CREATE TABLE IF NOT EXISTS features (
      id INTEGER PRIMARY KEY,
      external_id TEXT,
      magnitude REAL,
      place TEXT,
      time INTEGER,
      tsunami INTEGER,
      mag_type TEXT,
      title TEXT,
      longitude REAL,
      latitude REAL,
      url TEXT
    );
  SQL

  # Script para crear la tabla 'comments'
  DB.execute <<-SQL
    CREATE TABLE IF NOT EXISTS comments (
      id INTEGER PRIMARY KEY,
      feature_id INTEGER,
      body TEXT,
      FOREIGN KEY(feature_id) REFERENCES features(id)
    );
  SQL
end

# Verifica si las tablas existen, y si no, las crea
crear_tablas unless tablas_existen?

# Middleware para manejar las solicitudes OPTIONS y establecer los encabezados CORS
options '*' do
  response.headers['Access-Control-Allow-Origin'] = 'http://localhost:3000'
  response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-Requested-With, X-HTTP-Method-Override, Cache-Control, X-CSRF-Token'
  200
end

# Endpoint para obtener lista de features
get '/api/features' do
  content_type :json

  # Obtener parámetros de consulta
  mag_type = params['filters[mag_type]']
  page = params['page'].to_i
  per_page = [params['per_page'].to_i, 1000].min

  #consulta SQL
  sql = "SELECT * FROM features"
  conditions = []
  if mag_type
    conditions << "mag_type IN (#{mag_type.map { |mt| DB.quote(mt) }.join(',') })"
  end
  sql << " WHERE #{conditions.join(' AND ')}" unless conditions.empty?
  sql << " LIMIT #{per_page} OFFSET #{(page - 1) * per_page}" if per_page > 0

  puts sql
  puts mag_type
  # Obtener los features de la base de datos
  features = DB.execute(sql)

  # Formatear la respuesta
  data = features.map do |feature|
    {
      id: feature['id'],
      type: 'feature',
      attributes: {
        external_id: feature['external_id'],
        magnitude: feature['magnitude'],
        place: feature['place'],
        time: feature['time'],
        tsunami: feature['tsunami'],
        mag_type: feature['mag_type'],
        title: feature['title'],
        coordinates: {
          longitude: feature['longitude'],
          latitude: feature['latitude']
        }
      },
      links: {
        external_url: feature['url']
      }
    }
  end

  total_count = DB.execute("SELECT COUNT(*) FROM features").first[0]

  {
    data: data,
    pagination: {
      current_page: page,
      total: total_count,
      per_page: per_page
    }
  }.to_json
end

# Endpoint para crear un comentario asociado a un feature
post '/api/feature/comments' do
  request.body.rewind
  payload = JSON.parse(request.body.read)

  if payload['body'].nil? || payload['body'].empty?
    status 400
    body 'El cuerpo del comentario no puede estar vacío'
    return
  end

  feature_id = payload['feature_id']

  DB.execute("INSERT INTO comments (feature_id, body) VALUES (?, ?)", feature_id, payload['body'])

  status 201
  body 'Comentario creado exitosamente'
end
