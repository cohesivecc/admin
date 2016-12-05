
## P1
* Refile input - allow types other than images
* Search
* Filters
  * Specify in YAML:
    filter_by:
      job_type:
* Simple 'options' list (ie. User#user_type)

```yaml
name: Article
sort:
  column: position
fields:
  title:
    type: text
    label: 'Main Title'
  copy: wysiwyg
  links: association
  category:
    type: collection
    collection: Article::VALID_CATEGORIES
filters:
  featured:
    scope: featured
  by_issue:
    association: issue
```  


# class QuizDecorator
#   def title
#     { label:"Quiz Title", type:"Text", }
#   end


* Add default inputs for SimpleForm (take cues from Webflow?):
  * :color?
* Add 'type' to code editor (html, json, ruby)

* "Permanent" object concept - don't allow deletion?
  * Simply have the object respond to a permanent? method

* 'Preview' button ?
* accepts_nested_attributes_for
  * How can we allow assignment of already existing content?
  * Allow removal without destruction

* Turbolinks testing and conversion

## UI
* Add help text to YAML config
* Default sort items list by created date?
* Allow multiple columns in index view:
  * :to_label_columns (?) [:name, :category_name, :created_at]

## WYSIWYG - Images & Files
* Create similar proxy functionality for Files (a FileManager plugin)
* Keep this generalized so that if needed we could swap out the S3 backend?

## Generators
* Generate the YAML for a model (go through the admin_fields step and then write to a file)
* Generate directories for extensibility

## Extensibility
* Custom controller actions
* Custom views
* Customizing views through configs
* SimpleForm fields

## Documentation
* Polymorphic belongs_to: validating "inclusion: :in" for the 'type' column filters the list of classes to pick from.
* Configuring AWS will enable blanket uploads to S3 bucket from WYSIWYG editor
* S3 setup & IAM configuration
* collection input type && validates_inclusion_in
