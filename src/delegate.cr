# FIX: Figure out, if I want it to be seen in the error messages for 
# macro expansion
class Object
  macro delegate2(name, to, file = __FILE__, line = __LINE__)
   {% methods = @type.methods %}
   {% for a in @type.ancestors.map(&.methods) %}
     {% methods = methods + a %}
   {% end %}
   {% found_it = false %}
   {% for m in methods %}
     {% if m.name.id == name.id %}
       {% found_it = true %}
       {% if m.block_arg %}
         {% args = (m.args + ["&#{m.block_arg}".id]).splat %}
         {% yield_args = m.block_arg.restriction.inputs.map_with_index{|a,index| "arg#{index}".id}.splat %}
       {% else %}
         {% args = m.args.splat %}
         {% yield_args = "*args".id %}
       {% end %}
       # `{{@type.name}}.delegate2 {{name}}, to: {{to}}` at {{file.id}}:{{line.id}} to {{m.filename.id}}:{{m.line_number.id}}
       def {{name}}({{args}}) {% if !m.return_type.is_a?(Nop) %}: {{m.return_type}} {% end %}
         {{to}}.{{name}}({{m.args.map(&.internal_name).splat}}) {% if m.accepts_block? %}{ |{{yield_args}}| yield({{yield_args}})}{% end %}
       end
     {% end %}
   {% end %}
   {% if !found_it %}
     {% raise "delegate: Method \"#{name}\" wasn't found in \"#{@type.name}\"." %}
   {% end %}
   {% debug %}
  end
end

class A
  def foo()
    "String"
  end
end

class B
  @a = A.new
  A.delegate2 inspect, to: @a
end

b = B.new
