require "pg"
require "csv"
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "building-database")
    yield(connection)
  ensure
    connection.close
  end
end

# types_zones = []
# types_const = []

db_connection do |conn|
  # loop over the record in the csv file
  CSV.foreach('data.csv', headers: true) do |row|
    zoning_types = conn.exec(
      'SELECT name FROM zoning_types'
    )
    unless zoning_types.any? { |zoning_type| zoning_type["name"] == row[1] }
      conn.exec_params(
        'INSERT INTO zoning_types (name) VALUES($1)',
        [row[1]]
      )
    end

    ztype_id = conn.exec_params(
      'SELECT id FROM zoning_types WHERE name=$1', [row[1]]
    ) # return some sort of data structure that will contain id

    zoning_type_id = ztype_id[0]["id"]

    construction_types = conn.exec(
      'SELECT name FROM construction_types'
    )
    unless construction_types.any? { |construction_type| construction_type["name"] == row[2] }
      conn.exec_params(
      'INSERT INTO construction_types (name) VALUES ($1)',
      [row[2]]
      )
    end
    ctype_id = conn.exec_params(
      'SELECT id FROM construction_types WHERE name=$1', [row[2]]
    )
    construction_type_id = ctype_id[0]["id"]

    conn.exec_params(
      'INSERT INTO accounts (name, zoning_type_id, construction_type_id) VALUES($1, $2, $3)',
      [row[0], zoning_type_id, construction_type_id]
    )
end
    # check out zoning_type, construction_type
    # perfrom a sql query to determine if those records are present (zoming, construction)
    # if those zoning_type and construction_type records are not present,
      # we need to create that record
    # grab zoning_type and construction_type ids

    # insert account info into accounts table, and with it previosuly mentioned ids

  # types_zones.each do |type|
  #   conn.exec_params(
  #     'INSERT INTO zoning_types (name) VALUES($1)', [type])
  # end
  #
  # types_const.each do |type|
  #   conn.exec_params(
  #     'INSERT INTO construction_types (name) VALUES($1)', [type])
  # end

  # zoning_type_id = conn.exec_params(
  #   'SELECT id FROM zoning_types WHERE name=$1', ['Masonry']
  #   )
  # zoning_type_id = conn.exec_params(
  #   'SELECT id FROM zoning_types WHERE name=$2', ['Wood']
  #   )
  # zoning_type_id = conn.exec_params(
  #   'SELECT id FROM zoning_types WHERE name=$3', ['Reinforced Concrete']
  #   )
end

# construction_type_id = conn.exec_params(
#   'SELECT id FROM construction_types WHERE name=$1', ['Residential'],
#   'SELECT id FROM construction_types WHERE name=$2', ['Commercial']
# )
#
# db_connection do |conn|
#   conn.exec_params(
#     'INSERT INTO accounts (name, zoning_type_id, construction_type_id) VALUES($1, $2, $3)',
#     [
#       ["Ms. Jerrod Swift", zoning_type_id, construction_type_id],
#       ["Birdie Nikolaus", zoning_type_id, construction_type_id],
#       ["Mrs. Heath Bosco", zoning_type_id, construction_type_id]
#     ]
#   )
# end
