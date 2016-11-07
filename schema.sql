DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS zoning_types;
DROP TABLE IF EXISTS construction_types;

CREATE TABLE zoning_types (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255)
);

CREATE TABLE construction_types (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255)
);

CREATE TABLE accounts (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  zoning_type_id INT REFERENCES zoning_types(id),
  construction_type_id INT REFERENCES construction_types(id)
);
