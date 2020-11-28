class Object
  macro delegate2(name, to)
    {% methods = @type.methods %}
    {% got_name = false %}
    {% for m in methods %}
      {% if m.name.id == name.id %}
        {% got_name = true %}
        {% has_yield = false %}
        {% if m.body.class_name == "Expressions" %}
          {% for node in m.body.expressions %}
            {% if node.class_name == "Yield" %}
              {% has_yield = true %}
            {% end %}
          {% end %}
        {% end %}
        {% if m.body.class_name == "Yield" %}
          {% has_yield = true %}
        {% end %}
        def {{name}}({{m.args.join(",").id}}) {{ m.return_type.stringify != "" ? ": #{m.return_type}".id : "".id }}
          {{to}}.{{name}}({{m.args.map{ |arg| arg.internal_name }.join(", ").id}}) {{has_yield ? "do |*args| yield *args end".id : "".id}}
        end
      {% end %}
    {% end %}
    {% if !got_name %}
      {% raise "delegate: Method \"#{name}\" wasn't found in \"#{@type.name}\"." %}
    {% end %}
    {% debug %}
  end
end

class A
  def foo(a : Int32) : String
    yield
  end
end

class B
  @a = A.new
  A.delegate2(foo, to: @a)
end

b = B.new
p b.foo(1) { "Hello" }
