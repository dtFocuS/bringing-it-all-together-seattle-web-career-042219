class Dog
  attr_reader :id
  attr_accessor :name, :breed

  @@all = []

  def initialize(attributes, id=nil)
    @name = attributes[:name]
    @breed = attributes[:breed]
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      @@all << self
      self
    end
  end

  def self.create(name:, breed:)
    dog = self.new({name: name, breed: breed})
    dog.save
  end

  def self.find_by_id(id)
    @@all.find do |dog|
      dog.id == id
    end
  end

  def self.find_or_create_by(hash)
    #target_dog = nil
    #@@all.each do |dog|
      #if dog.name == hash[:name] && dog.breed == hash[:breed]
        #target_dog = dog
      #end
    #end
    #if target_dog == nil
      #self.create(name:hash[:name], breed:hash[:breed])
    #else
      #target_dog
    #end
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?;
    SQL
    dog_array = DB[:conn].execute(sql, hash[:name], hash[:breed])
    if dog_array.size > 0
      @@all.find do |dog|
        dog.id == dog_array.flatten[0]
      end
    else
      self.create(name:hash[:name], breed:hash[:breed])
    end
  end

  def self.new_from_db(row)
    self.create(name:row[1], breed:row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * from dogs WHERE name = ?;
    SQL
    array = DB[:conn].execute(sql, name).flatten
    @@all.find {|dog| dog.name == array[1]}
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
