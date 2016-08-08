require 'pry'

class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        #binding.pry
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)

        sql = <<-SQL
        CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ? WHERE id = ?
            SQL
            DB[:conn].execute(sql, name, breed, id)
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
        end
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
      dog.save
        dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        dog = DB[:conn].execute(sql, id).flatten
        dog
        #binding.pry
        self.new_from_db(dog)
    end


    def self.new_from_db(row)
#binding.pry
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
        dog

   end


    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        dog = DB[:conn].execute(sql, name).first
        self.new_from_db(dog)
    end



    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed =?"
        result = DB[:conn].execute(sql, name, breed).first
        if result == nil
            dog = self.create(name: name, breed: breed)
        else
            dog = self.new_from_db(result)
        end
        dog
    end


end
