module Admin::ProblemsHelper
  def link_to_add_fields(name = nil, f = nil, association = nil, options = {}, html_options = {}, &block)
    f, association, options, html_options = name, f, association, options if block_given?

    locals = options.fetch(:locals, {})

    if options.include? :partial
      partial = options[:partial]
    else
      partial = association.to_s.singularize + '_fields'
    end

    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, child_index: 'new_record') do |builder|
      render(partial, locals.merge!(f: builder))
    end

    html_options['data-form-prepend'] = raw CGI::escapeHTML(fields)

    content_tag(:button, name, html_options.merge(type: "button"), &block)
  end

  def tags_list(problem, full, id = false)
    return '' if problem.tags.empty?

    if full
      if id
        problem.tags.distinct.pluck(:id).join(',')
      else
        problem.tags.distinct.pluck(:description).join(';')
      end
    else
      if id
        problem.tags.first.id.to_s
      else
        problem.tags.first.description
      end
    end
  end
end
