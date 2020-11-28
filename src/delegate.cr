class Object
  macro delegate2(name, to)
   {% if m = @type.methods.find &.name.id.==(name.id) %}
     {% if m.block_arg %}
       {% args = m.block_arg.restriction.inputs %}
       {% yield_args = args.map_with_index{|a,index| "arg#{index}".id}.splat %}
     {% else %}
       {% yield_args = "*args".id %}
     {% end %}
     def {{name}}({{(m.args + ["&#{m.block_arg}".id]).splat}}) {% if !m.return_type.is_a?(Nop) %}: {{m.return_type}} {% end %}
       {{to}}.{{name}}({{m.args.map(&.internal_name).splat}}) {% if m.accepts_block? %}{ |{{yield_args}}| yield({{yield_args}})}{% end %}
     end
   {% else %}
     {% raise "delegate: Method \"#{name}\" wasn't found in \"#{@type.name}\"." %}
   {% end %}
   {% debug %}
  end
end

class A
  def foo(a : Int32, &block : Int32 -> String) : String
    yield a
  end
end

class B
  @a = A.new
  A.delegate2 foo, to: @a
end

b = B.new
p b.foo(1) { |i| "Hello" }
