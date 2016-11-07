### Introduction

You are tasked with taking old CSV data and placing that info into a nice, normalized database.
The CSV data represents buildings and their owners. Each record has a name, a zoning type, and a construction type.
Notice the duplication of data in the latter two columns.  

#### Resources

- [Ruby's CSV library](http://ruby-doc.org/stdlib-2.3.0/libdoc/csv/rdoc/CSV.html)
- [TutorialsPoint Postgres Reference](https://www.tutorialspoint.com/postgresql/index.htm)

#### Learning Goals

- What does database normalization look like? We will compare and contrast CSV data storage and relational database storage.
- How do we construct `INSERT` and `SELECT` queries in a meaningful way? Does the order in which we insert records matter?
- What does the term *'dependency'* mean in the context of a database?

### Instructions

#### Setup

```no-highlight
$ et get building-a-database
```

This exercise requires the `pg` gem. If you don't already have it installed, let's do that:

```no-highlight
$ gem install pg
```

This exercise will require the creation of a database:

```no-highlight
$ createdb building-database
```

#### Create A Schema

For this exercise, you will want create three tables: `accounts`, `zoning_types`, and `construction_types`.
Use the provided `schema.sql` to create a suitable schema.

```sql
CREATE TABLE zoning_types (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255)
);
```

Once you are ready to apply this schema to your newly created database, import the schema like so:

```no-highlight
$ psql building-database < schema.sql
```

#### Drop It Like It's Hot

The previous step may take you more than one attempt, and you may realize that you need to alter your schema throughout this exercise.
If you run the schema command more than once, you will probably get errors like this:

```no-highlight
Relation 'zoning_types' already exists.
```

This error, believe it or not, is a safety feature.
This is Postgres telling you, "Hey, if you're going to overwrite this table and the data it contains, you should be explicit about it."
The issue is that we are not being explicit enough with our code.

To ensure that the schema file imports correctly *each time*, you will want to provide explicit instructions to drop all of your tables at the beginning of your schema file:

```sql
DROP TABLE IF EXISTS zoning_types;
```

You will want one sql query like this for each table.

#### Foreign Keys

You will want to make `zoning_type_id` and `construction_type_id` foreign key columns on your `accounts` table.
Integer values will populate these columns, and these values will reference the primary keys of records on their respective tables.

```no-highlight
accounts
id | name             | zoning_type_id | construction_type_id
-------------------------------------------------------------
1  | Ms. Jerrod Swift | 1              | 1
2  | Birdie Nikolaus  | 1              | 2
3  | Mrs. Heath Bosco | 2              | 3


zoning_types
id | name
----------------
1  | Residential
2  | Commercial


construction_types
id | name
----------------
1  | Masonry
2  | Wood
3  | Reinforced Concrete
```

Notice how we are defining each construction type and each zoning type *exactly* once.
This is contrast to our CSV data, where these data points are defined over and over again.
When the data is stored in this way (reducing redundancies to 0), it is considered *normalized*.
This is highly advantageous since we are defining data points *in one place*, and we are saving on disk space at the same time.
If we decide to change these zoning and construction types later on, we only need to modify them in one place.
This is both convenient and ensures that our data is more accurate.

__Note:__ Remember that we don't need to manage the creation of our primary keys.
As long as we `SERIAL`ize the primary key column when creating a table, the creation of primary keys for new records will be done for us!

#### Transfer Data with Ruby

Once your schema is imported, now comes the time to transfer data from the CSV file to your database.
Use the provided `import.rb` file to accomplish this task.
Your `accounts` table will have many records, but your other tables will have few, one for each *unique* zoning and construction type.

#### Dependencies

The creation of an `account` record relies on existing records in the other two tables, since an `account` record requires the inclusion of foreign key values.
Because of this, the `accounts` table is *dependent* on the others.
It is recommended that you create new records *IF needed* in the zoning and construction tables before attempting to insert a new `account` record.

For example, let's pretend that we're iterating over the CSV data and we're about to insert the first record into our database:

```no-highlight
Ms. Jerrod Swift,Residential,Masonry
```
We know at this point that the `Residential` and `Masonry` records don't exist in their respective tables, since we have just started to add records. You will need to:

1. Insert these records into `zoning_types` and `construction_types`

```ruby
db_connection do |conn|
  conn.exec_params(
    'INSERT INTO zoning_types (type_name) VALUES($1)',
    ["Masonry"]
  )
end
```

2. Execute 2 more SQL queries to retrieve the primary key of these records. These records can be looked up by their name.

```ruby
zoning_type_id = conn.exec_params(
  'SELECT id FROM zoning_types WHERE name=$1',
  ["Masonry"]
)
```

3. Insert the new `accounts` record with the primary key you have retrieved

```ruby
conn.exec_params(
  'INSERT INTO accounts (name, zoning_type_id, construction_type_id) VALUES($1, $2, $3)',
  ["Ms. Jerrod Swift", zoning_type_id, construction_type_id]
)
```

These are just snippets of code to help you get started, and are by no means what you *exactly* need.

#### Conclusion

You can verify your work by going into `psql` itself and performing whatever SQL query you would like on your database:

```no-highlight
$ psql building-database
database-name=# SELECT * FROM accounts;
```

When you are done, you should have non-duplicated data in your database. Do not worry about verifying if account names are unique. They are already unique. Congrats! You have successfully normalized this set of data in a relational database!
