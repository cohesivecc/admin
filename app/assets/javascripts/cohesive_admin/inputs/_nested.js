window.NestedInput = class NestedInput {

  static initialize() {
    if(typeof(Handlebars) !== 'undefined') { // Handlebars is required
      return $('[data-nested]').each( function() {
        if($(this).data('nested') === '') {
          return $(this).data('nested', new NestedInput($(this)));
        }
      });
    }
  }

  constructor(ele) {

    this.add = this.add.bind(this);
    this.destroy = this.destroy.bind(this);
    this.ele = ele;
    this.t        = $(this.ele).children('[data-nested-template]');
    this.key      = this.t.data('nested-template');
    this.t_html   = this.t.remove().html();

    const ind_regex = new RegExp("__"+this.key+"_index__", 'g');
    const obj_regex = new RegExp("__"+this.key+"_object_id__", 'g');

    this.t_html   = this.t_html.replace(obj_regex, "{{"+this.key+"_object_id}}").replace(ind_regex, "{{"+this.key+"_index}}");


    // @template = Handlebars.compile($(@ele).children('[data-nested-template]').remove().html())
    this.template = Handlebars.compile(this.t_html);
    this.list     = $(this.ele).children('[data-nested-list]');

    this.list.off('click.collapse', '> li a[data-nested-add]').on('click.collapse', '> li a[data-nested-add]', e => {
      e.preventDefault();
      e.stopPropagation();
      return this.add();
    });

    this.list.on('click', '> li a[data-nested-destroy]', e => {
      e.preventDefault();
      e.stopPropagation();
      return this.destroy($(e.currentTarget).data('nested-destroy'));
    });
  }

  add() {
    const timestamp = new Date().getTime();
    const data = { };
    data[this.key+"_index"]     = timestamp;
    data[this.key+"_object_id"] = timestamp;
    this.list.children('li:last').before( this.template(data) );
    NestedInput.initialize();
    return $(document).trigger('cohesive_admin.form_change'); // re-initialize any new select boxes, etc.
  }

  destroy(id) {
    if(confirm("Are you sure you want to delete this item?")) {
      const li = this.list.children('[data-nested-object="'+id+'"]');
      if(li.length) {
        li.find('input[id$="_destroy"]').val('1');
        return li.hide();
      }
    }
  }
};


$(document).on('cohesive_admin.initialized', () => NestedInput.initialize());
