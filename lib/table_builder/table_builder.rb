module TableHelper

  def table_for(objects, *args)
    raise ArgumentError, "Missing block" unless block_given?
    options = args.last.is_a?(Hash) ? args.pop : {}
    html_options = options[:html]
    builder = options[:builder] || TableBuilder
    
    concat(tag(:table, html_options, true))
    yield builder.new(objects || [], self, options)
    concat('</table>'.html_safe!)
  end

  class TableBuilder
    include ::ActionView::Helpers::TagHelper

    def initialize(objects, template, options)
      raise ArgumentError, "TableBuilder expects an Array but found a #{objects.inspect}" unless objects.is_a? Array
      @objects, @template, @options = objects, template, options
    end

    def head(*args)
      if block_given?
        concat(tag(:thead, options_from_hash(args), true))
        yield
        concat('</thead>'.html_safe!)
      else        
        @num_of_columns = args.size
        content_tag(:thead,
          content_tag(:tr,
            args.collect { |c| content_tag(:th, c)}.join('')
          )
        )
      end
    end

    def head_r(*args)
      raise ArgumentError, "Missing block" unless block_given?
      options = options_from_hash(args)
      head do
        concat(tag(:tr, options, true))
        yield
        concat('</tr>'.html_safe!)
      end
    end

    def body(*args)
      raise ArgumentError, "Missing block" unless block_given?
      options = options_from_hash(args)
      tbody do
        @objects.each { |c| yield(c) }
      end
    end
    
    def body_r(*args)
      raise ArgumentError, "Missing block" unless block_given?
      options = options_from_hash(args)
      tbody do
        @objects.each { |c|
          concat(tag(:tr, options, true))
          yield(c)
          concat('</tr>'.html_safe!)
        }
      end
    end    

    def r(*args)
      raise ArgumentError, "Missing block" unless block_given?
      options = options_from_hash(args)
      tr(options) do
        yield
      end
    end

    def h(*args)
      if block_given?
        concat(tag(:th, options_from_hash(args), true))
        yield
        concat('</th>'.html_safe!)
      else
        content = args.shift
        content_tag(:th, content, options_from_hash(args))
      end        
    end

    def d(*args)
      if block_given?
        concat(tag(:td, options_from_hash(args), true))
        yield
        concat('</td>'.html_safe!)
      else
        content = args.shift
        content_tag(:td, content, options_from_hash(args))
      end        
    end
    

    private
    
    def options_from_hash(args)
      args.last.is_a?(Hash) ? args.pop : {}
    end
    
    def concat(tag)
       @template.concat(tag)
    end

    def content_tag(tag, content, *args)
      options = options_from_hash(args)
      @template.content_tag(tag, content, options)
    end
    
    def tbody
      concat('<tbody>'.html_safe!)
      yield
      concat('</tbody>'.html_safe!)
    end
    
    def tr options
      concat(tag(:tr, options, true))
      yield
      concat('</tr>'.html_safe!)      
    end
  end
end