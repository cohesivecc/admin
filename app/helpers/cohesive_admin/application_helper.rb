module CohesiveAdmin
  module ApplicationHelper

    def inverse_relationship_exists?(child, association, parent)
      return false unless child && association && parent

      association = association.to_s
      if child_r = child.reflections[association]
        if child_r.polymorphic?
          parent.reflections.each do |k,v|
            if v.options[:as] == child_r.name
              return true
            end
          end
          return false
        else
          (parent.reflections.values.include?(child_r.inverse_of) rescue false)
        end
      end

    end

    def link_to_add_nested(name, f, association)
      new_object = f.object.send(association).klass.new
      id = new_object.object_id
      fields = f.fields_for(association, new_object, child_index: id) do |builder|
        render("cohesive_admin/base/fields", klass: new_object.class, f: builder)
      end

      fields = "<div class='card-panel blue lighten-5'>" + fields + "</div>"
      link_to(name, '#', class: "add_fields", data: { add: '', id: id, fields: fields.gsub("\n", "")})
    end

  end
end
