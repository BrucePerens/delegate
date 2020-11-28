class Object
  macro delegate2(name, to)
    {% methods = @type.methods %}
    {% for m in methods %}
      {% if m.name.id == name.id %}
        {% has_yield = m.body.stringify.includes?("yield") %}
        {% if has_yield %}
          {% raise "delegate() called on a method with a block." %}
        {% end %}
        def {{name}}({{m.args.join(",").id}}) {{ m.return_type.stringify != "" ? ": #{m.return_type}".id : "".id }}
        end
      {% end %}
    {% end %}
  end
end

class A
  def foo(a : Int32) : String
    yield
    "Hello from A#foo!"
  end
end

class B
  @b = A.new
  A.delegate2(foo, to: @b)
end

b = B.new
b.foo(1) do |t|
  p "Block!"
end

