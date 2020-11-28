class Object
  macro delegate(name, to)
    {% methods = @type.methods %}
    {% for m in methods %}
      {% if m.name.id == name.id %}
        {% begin %}
          def {{name}}({{m.args.join(",").id}}) {{ m.return_type.stringify != "" ? ": #{m.return_type}".id : "".id }}
            {{to}}.{{name}}({{m.args.map{ |arg| arg.internal_name }.join(", ").id}})
          end
        {% end %}
      {% end %}
    {% end %}
  end
end

class A
  def foo(a : Int32) : String
    "Hello from A#foo!"
  end
end

class B
  @b = A.new
  typeof(@b).delegate(foo, to: @b)
end

b = B.new
p b.foo(1)
