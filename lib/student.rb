require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade, :id

  def initialize(id=nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = %Q(
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    )
    DB[:conn].execute(sql)
  end

  def self.drop_table

    sql = %Q(
      drop table students
    )
    DB[:conn].execute(sql)
    #ALTENATIVELY
    # sql = "DROP TABLE students"
    # DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = %Q(
        insert into students(name, grade)
        values (?,?)
      )
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("select last_insert_rowid() from students")[0][0]
      self
    end  
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
  end


  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)
  end
  

  def self.find_by_name(name)
    sql = "select * from students where name = ? limit 1"
    DB[:conn].execute(sql, name).map do |item|
      self.new_from_db(item)
    end.first
  end


  def update
    sql = "UPDATE students 
    SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end



end
