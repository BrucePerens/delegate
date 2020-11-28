class Object
  macro delegate2(name, to)
   {% methods = @type.methods %}
   {% for a in @type.ancestors.map(&.methods) %}
     {% methods = methods + a %}
   {% end %}
   {% if m = methods.find &.name.id.==(name.id) %}
     {% if m.block_arg %}
       {% args = (m.args + ["&#{m.block_arg}".id]).splat %}
       {% yield_args = m.block_arg.restriction.inputs.map_with_index{|a,index| "arg#{index}".id}.splat %}
     {% else %}
       {% args = m.args.splat %}
       {% yield_args = "*args".id %}
     {% end %}
     def {{name}}({{args}}) {% if !m.return_type.is_a?(Nop) && m.return_type.stringify != "Nil" %}: {{m.return_type}} {% end %}
       {{to}}.{{name}}({{m.args.map(&.internal_name).splat}}) {% if m.accepts_block? %}{ |{{yield_args}}| yield({{yield_args}})}{% end %}
     end
   {% else %}
     {% raise "delegate: Method \"#{name}\" wasn't found in \"#{@type.name}\"." %}
   {% end %}
   {% debug %}
  end
end

class A
  def foo(a : Int32, b : Int32, &block : Int32, Int32 -> String) : String
    yield a, b
  end
end

class B
  @a = A.new
  A.delegate2 inspect, to: @a
end

b = B.new
