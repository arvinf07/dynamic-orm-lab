require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  def self.column_names
    sql = "PRAGMA table_info('#{self.table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |column|
      column_names << column["name"]
    end

    column_names.compact
  end  

  def initialize(attr_hash = {}) 
    attr_hash.each do |attr_name, attr_value|
      self.class.attr_accessor attr_name
      self.send("#{attr_name.to_s}=", attr_value) unless attr_name.to_s == "id"
    end
    self  
  end  

  def self.table_name
    table_name = self.to_s.downcase.pluralize
  end  

  def table_name_for_insert
    self.class.table_name
  end  

  def col_names_for_insert
    self.class.column_names.map do |col_name|
      col_name 
    end.slice(1..-1).join(', ')
  end  

  def values_for_insert
    values = self.class.column_names.map do |col_name| 
      send(col_name) 
    end  
    values.map do |col_name| 
      "'#{col_name}'" 
    end.slice(1..-1).join(', ')
  end  

  def save 
    sql = "INSERT INTO #{self.class.table_name} (#{col_names_for_insert})
    VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].last_insert_row_id
  end  

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name}
     WHERE name = ? LIMIT 1"

    DB[:conn].execute(sql, name) 
  end  

  def self.find_by(attr_hash = {})
    col_name, col_value = attr_hash.keys.first.to_s, attr_hash.values.first
    sql = "SELECT * FROM #{table_name}
      WHERE #{col_name} IS '#{col_value}'"
    #binding.pry
    DB[:conn].execute(sql)  
  end  


end