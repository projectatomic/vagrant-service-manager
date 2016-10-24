require 'cucumber/formatter/pretty'

class CiFormatter < Cucumber::Formatter::Pretty
  # A patch version of after_table_row which will also display the status in the table
  # See https://github.com/projectatomic/vagrant-service-manager/issues/419
  def after_table_row(table_row)
    return if !@table || @hide_this_step
    print_table_row_messages
    @io.print ' Result' if table_row.status.nil?
    @io.print " #{table_row.status.to_s.upcase}" unless table_row.status.nil?
    @io.puts
    return if !table_row.exception || @exceptions.include?(table_row.exception)
    print_exception(table_row.exception, table_row.status, @indent)
  end
end
