# CohesiveAdmin

CohesiveAdmin is a simple Rails engine that give you a basic, customizeable admin interface for users to make database updates. The goal of this engine is to be unobtrusive, decoupled from your Rails application, and most importantly - simple. Customization is handled via custom [Simple Form](https://github.com/plataformatec/simple_form) inputs and YAML configuration.

## CohesiveAdmin Models
#### CohesiveAdmin::User
This is the basic user model used for logging in to the CMS.

## UI
CohesiveAdmin uses the [Materialize](http://materializecss.com/) CSS framework.


## Best Practices
  * Make use of the :inverse_of option in your ActiveRecord relationships. This prevents nested fields on an object from displaying in the form. http://guides.rubyonrails.org/association_basics.html#bi-directional-associations
  * For nested attributes functionality, be sure that both the parent model and the nested attributes model are managed resources (`cohesive_admin`)

## WYSIWYG Editor and File Uploads
We use the [Froala WYSIWYG Editor](https://www.froala.com/wysiwyg-editor) for rich text fields. Froala has built-in support for direct asset uploads to [Amazon S3](https://aws.amazon.com/s3/). This makes for a convenient way to allow users to upload images and files to one central location without having to model them in your application. These assets should be stored independent of any other assets - either in a specific subdirectory in S3 (see the `key_start` param), or in a completely separate bucket. **NOTE:** Because enabling S3 uploads via Froala requires specific CORS configuration on the bucket, carefully consider whether or not using a shared bucket is appropriate for your situation.


## Installation
Add it to your Gemfile:

```ruby
gem 'cohesive_admin', git: 'git@github.com:cohesivecc/admin.git', tag: "<specific tag number here>"
```

Install the migrations:

```console
rake cohesive_admin:install:migrations
```

In development, password validation is disabled for both user creation, as well as authentication. This makes it easy to create test users in development and log in to the admin interface with any account.

To create a new user via the IRB console:

```ruby
u = CohesiveAdmin::User.create({ email: 'bob@example.com', password: 'doesNOTmatter', name: 'Admin User' })
```

## Managing Models

To use the cohesive_admin gem to manage models in the database add cohesive_admin to your model

```ruby
cohesive_admin
```

The cohesive_admin gem will read the database table for the models that call the cohesive_admin method in them.  It will default to the types chosen by simple_form.  

## Customizing the admin

It is possible to customize the fields that are available inside the admin.  These are configured through YAML files inside config/cohesive_admin. Name the YAML file the same as the model that the cohesive_admin gem is managing.  A rails model of Address would have an address.rb file in the models directory; create an address.yml file in config/cohesive_admin and the resource will be created when the application is started up.  You can see this working in the test/dummy section of this repository.

```yml
fields:
  name:
  wysiwig_example: wysiwyg
  association_example: association
  text_field_example: text
  boolean_example: boolean
  checkbox_example: checkbox
  code_example: code
```

## Sorting

The admin allows you to add a column to use to sort the order of the records in the admin.  Make sure the model has a column in the database to save the sorting value.  Add the key sort to the model's yml file with the column you wish to use to sort against. In the example below we have the key of "sort" and the value of "position".

```yml
sort: position
```

## Filtering

Columns in the database can be filtered. You can enable filtering on a field by adding key value pairs to the field.  See the example below. In the example below to see how to enable filtering for the name and association_example fields.

```yml
fields:
  name:
    type: string
    filter: true
  wysiwig_example: wysiwyg
  association_example:
    type: association
    filter: true
  text_field_example: text
  boolean_example: boolean
  checkbox_example: checkbox
  code_example: code
```

## Duplicating Records

The cohesive_admin allows for an email way to duplicate a record.  You can enable this feature on a model by adding a key "duplicate" and the value "true" to the yml file.

```yml
duplicate: true
```

## Navigation order

The order of the models in the navigation can be customized.  You can define an order by using the key "order" in the yml file.  The order will first be sorted by the number provided then alphabetically. If this is not defined they will be sorted alphabetically.

```yml
order: 0
```

## Help Text and Labels

It is possible to add help text or change the label for a field.  See example below:

```yml
fields:
  name:
    type: string
    help: "Put your help text here"
    label: Label Here
  wysiwig_example: wysiwyg
  association_example: association
  text_field_example: text
  boolean_example: boolean
  checkbox_example: checkbox
  code_example: code
```

## Populating Dropdowns

A dropdown can be populated by using validations to the model.

```ruby
validates :field_name, inclusion: { in: ['Value 1', 'Value 2'] }
```
