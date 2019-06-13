require_relative "../config/environment.rb"
  class Student

    attr_accessor :name, :grade
    attr_reader :id

    def initialize(id=nil, name, grade)
      @id = id
      @name = name
      @grade =grade
    end

    def self.create_table
      sql = <<-SQL
      create table students (
        id integer primary key,
        name text,
        grade text
      )
      SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
      DB[:conn].execute("drop table if exists students")
    end

    def save
      if self.id
        self.update
      else
        sql = "insert into students (name, grade) values (?, ?)"
        DB[:conn].execute(sql, self.name, self.grade)
        @id = DB[:conn].execute("select last_insert_rowid() from students")[0][0]
      end
    end

    def self.create(name, grade)
      Student.new(name, grade).save
    end

    def self.new_from_db(row)
      self.new(row[0], row[1], row[2])
    end

    def self.find_by_name(name)
      sql = "select * from students where students.name = ? limit 1"
      DB[:conn].execute(sql, name).collect { |row| self.new_from_db(row)}.first
    end

    def update
      sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end

  end