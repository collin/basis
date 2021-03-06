$LOAD_PATH.unshift(File.expand_path("#{File.dirname(__FILE__)}/../lib"))

require "spec"
require "basis"

module Spec::Expectations::ObjectExpectations
  alias_method :must, :should
  alias_method :must_not, :should_not
  undef_method :should
  undef_method :should_not
end

Spec::Runner.configure do |config|
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure 
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end
  
  alias silence capture
end

FIXTURES_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "fixtures")
