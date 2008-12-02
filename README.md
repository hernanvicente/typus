# Typus

As Django Admin, Typus is designed for a single activity:

> Trusted users editing structured content.

Keep in mind that:

> Typus doesn't try to be all the things to all the people.

Once installed and configured you can login at <http://example.com/admin>.

Screenshots on the [wiki](http://github.com/fesplugas/typus/wikis).

## Installing

You can view the available tasks running:

    $ rake -T typus
    (in /home/fesplugas/projects/typus_platform)
    rake typus:dependencies  # Install Typus dependencies (paperclip, acts_as_l....
    rake typus:roles         # List current roles
    rake typus:specs         # Generate specdoc-style documentation from tests

### Configure

This task copies required assets to the public folder of your Rails 
application, generates configuration files on `config` folder and 
generates the required database migration files.

    $ script/generate typus_files

After creating the files migrate your database:

    $ rake db:migrate

And finally create the first user, to do it, start the application 
server, go to <http://0.0.0.0:3000/admin> and follow the instructions.

## Plugin Configuration Options

You can overwrite the following settings:

    Typus::Configuration.options[:app_name]
    Typus::Configuration.options[:app_description]
    Typus::Configuration.options[:per_page]
    Typus::Configuration.options[:form_rows]
    Typus::Configuration.options[:form_columns]
    Typus::Configuration.options[:minute_step]
    Typus::Configuration.options[:email]
    Typus::Configuration.options[:toggle]
    Typus::Configuration.options[:edit_after_create]
    Typus::Configuration.options[:root]
    Typus::Configuration.options[:recover_password]
    Typus::Configuration.options[:password]
    Typus::Configuration.options[:special_characters_on_password]
    Typus::Configuration.options[:ssl]

You can overwrite this settings in the initializer `typus.rb`.

### Special Route

To overwrite the default prefix path of your application place the 
following configuration option on `development.rb`, `production.rb` 
on the `config/environments` folder.

    Typus::Configuration.options[:prefix] = "backoffice"

### Disable password recover

You can disable password recover on the login page. By default, password
recovery is enabled.

    Typus::Configuration.options[:recover_password] = false

### Disallow toggle

When you have a boolean on the lists you can toggle it's status from 
true to false and false to true. You can disable this link with:

    Typus::Configuration.options[:toggle] = false

### Redirect to index after create a record

After creating a new record you'll be redirected to the record so 
you can continue editing it. If you prefer to be redirected to the 
main index you can owerwrite the setting.

    Typus::Configuration.options[:edit_after_create] = false

## Configuration file options

You can configure all **Typus** settings from the `application.yml` 
file located under the `config/typus` folder. This file is created 
once you run the `typus_files` generator.

### Typus Fields

    fields:
      list: name, created_at, category, status
      form: name, body, created_at, status
      relationship: name, category

NOTE: Upload files only works if you follow `Paperclip` naming 
conventions.

In form fields you can have read only fields and read only fields for 
autogenerated content. These kind of fields will be shown in the form 
but won't be editable. Example with the "name" attribute being read-only:

    fields:
      list: name, created_at, category, status
      form: name, body, created_at, status
      relationship: name, category
      options:
        read_only: name

To define `auto generated` fields.

    Order:
      fields:
        list: tracking_number, first_name, last_name
        form: tracking_number, first_name, last_name
        options:
          auto_generated: tracking_number

You can then initialize it from the model.

    ##
    # app/models/order.rb
    #
    class Order < ActiveRecord::Base

      def initialize_with_defaults(attributes = nil, &block)
        initialize_without_defaults(attributes) do
          self.tracking_number = Random.tracking_number
          yield self if block_given?
        end
      end

      alias_method_chain :initialize, :defaults

    end

You can even add "virtual fields". For example you have a model and you 
need special attributes like an slug, which is generated from the title.

    ##
    # app/models/post.rb
    #
    class Post < ActiveRecord::Base

      validates_presence_of :title

      def slug
        title.parameterize
      end

    end

You can add `slug` a as attribute and it'll be shown on the lists.

    ##
    # config/typus/application.yml
    Post:
      fields:
        list: title, slug
        form: title

### External Forms

Typus will detect automatically which kind of relationships has the model.

    relationships: users, projects

### Filters

You can define filters per model on the config file ...

    filters: status, author, created_at

Or directly on the model:

    class Post < ActiveRecord::Base

      def self.admin_filters
        [ :status, :author, :created_at ]
      end

    end

### Order

Adding minus (-) sign before the attribute will make the order DESC.

    order_by: -attribute1, attribute2

Or directly on the model:

    class Post < ActiveRecord::Base

      def self.admin_order_by
        [ '-attribute1', 'attribute2' ]
      end

    end

### Searches

You can define search filters on `config/typus/application.yml`

    search: attribute1, attribute2

Or directly on the model:

    class Post < ActiveRecord::Base

      def self.admin_search
        [ :attribute1, :attribute2 ]
      end

    end

### Questions?

Sometimes on your forms you want to ask questions.

- Is highlighted?
- On newsletter?

And you can enable them with the questions option.

    Story:
      fields:
        list: title, is_highlighted
        form: title, body, is_highlighted
        options:
          questions: is_highlighted

### Selectors

Need a selector, to select gender, size, status, the encoding status 
of a video or whatever in the model? 

    Person:
      fields:
        list: ...
        form: first_name, last_name, gender, size, status
        options:
          selectors: gender, size, status

From now on the form, if you have enabled them on the list/form you'll see 
a selector with the options that you define in your model.

Example:

    ##
    # app/models/video.rb
    #
    class Video < ActiveRecord::Base

      validates_inclusion_of :status, :in => self.status

      def self.status
        %w( pending encoding encoded error published )
      end

    end

    ##
    # config/typus/application.yml
    #
    Video:
      fields:
        list: title, status
        form: title, status
        options:
          selectors: status

If the selector is not defined, you'll see a **text field** instead of a 
*select field*.

### Want more actions?

    Post:
      fields:
        list: ...
        form: ...
      actions:
        index: notify_all
        edit: notify

These actions will only be available on the requested action.

You can add those actions to your admin controllers. Example:

    class Admin::NewslettersController < AdminController

      ##
      # Action to deliver emails ...
      def deliver
        ...
        redirect_to :back
      end

    end

For feedback you can use the following flash methods.

- `flash[:notice]` just some feedback.
- `flash[:error]` when there's something wrong.
- `flash[:success]` when the action successfully finished.

### Applications, modules and submodules

To group modules into an application use *application*.

    application: CMS

Each module has submodules grouped using *module*.

    module: Article

Example: (E-Commerce Application)

    Product:
      application: ECommerce
    Client:
      application: ECommerce
    Category:
      module: Product
    OptionType:
      module: Product

Example: (Blog)

    Post:
      application: Blog
    Category:
      application: Blog
    Tag:
      module: Post

## Custom Views

You can add your custom views to match your application requirements. Views 
you can customize.

    index.html.erb
    edit.html.erb
    show.html.erb

### Example

Need a custom view on the Articles listing? 

Under `app/view/admin/articles` add the file `index.html.erb` and 
Typus default `index.html.erb` will be replaced.

## Customize Interface

You can customize the interface by placing on `views/admin` the 
following files.

### Login Page

    views/admin/login/_bottom.html.erb
    views/admin/login/_top.html.erb

### Dashboard

    views/admin/dashboard/_bottom.html.erb
    views/admin/dashboard/_sidebar.html.erb
    views/admin/dashboard/_top.html.erb

### Models

    views/admin/MODEL/_edit_bottom.html.erb
    views/admin/MODEL/_edit_sidebar.html.erb
    views/admin/MODEL/_edit_top.html.erb
    views/admin/MODEL/_index_bottom.html.erb
    views/admin/MODEL/_index_sidebar.html.erb
    views/admin/MODEL/_index_top.html.erb
    views/admin/MODEL/_new_bottom.html.erb
    views/admin/MODEL/_new_sidebar.html.erb
    views/admin/MODEL/_new_top.html.erb
    views/admin/MODEL/_show_bottom.html.erb
    views/admin/MODEL/_show_sidebar.html.erb
    views/admin/MODEL/_show_top.html.erb

Example:

    views/admin/posts/_index_top.html.erb
    views/admin/typus_users/_edit_top.html.erb

## Roles

Typus has roles support. You can can add as many roles as you want. 
They are defined in `config/typus/application_roles.yml` and you 
can can define the allowed actions per role.

    admin:
      TypusUser: create, read, update, delete
      Post: create, read, update, delete, rebuild
      Category: create, read, update, delete

    editor:
      Post: create, update
      Category: create, update

## Resources which are not models

Want to manage **memcached**, see the current **starling** queue or have 
an special resource which is not related to any model?

    ##
    # config/typus/application_roles.yml
    admin:
      Backup: index, download_db, download_media
      MemCached: index
      ApplicationLog: index
      Git: index, commit

When you start **Typus** a controller and a view will be created.

    app/controllers/admin/backup_controller.rb
    app/views/admin/backup/index.html

## Typus & SSL

You can use SSL on Typus. To enable it update the initializer.

    Typus::Configuration.options[:ssl] = true

Remember to install the `ssl_requirement` plugin to be able to use this 
feature.

    $ script/plugin install git://github.com/rails/ssl_requirement.git

## Tip & Tricks

### Roles for a user?

You can create a role for a user using directly the username nickname. For 
example, the user Francesc Esplugas:

    fesplugas:
      TypusUser: update
      Post: create, read, update, delete

## Testing the plugin

You can test the plugin by running `rake`. Tests will be performed against 
a SQLite3 database in memory. You can also run tests against PostgreSQL and 
MySQL databases. You have to create databases, both are called `typus_test`. 
Once you've created them you can run the tests.

    $ rake DB=mysql
    $ rake DB=postgresql

## Splitting configuration files

You can split your configuration files in several files so it can be easier 
to mantain.

    config/typus/application.yml
    config/typus/newsletter.yml
    config/typus/blog.yml
    config/typus/application_roles.yml
    config/typus/newsletter_roles.yml
    config/typus/blog_roles.yml

## Acknowledgments

- Laia Gargallo (My girl) - <http://azotacalles.net>
- Isaac Feliu (Help on refactoring) - <http://railslab.net>
- Sergio Espeja (Feedback & patches) - <http://github.com/spejman>
- Lluis Folch (Icons, feedback & crazy ideas) - <http://wet-floor.com>

## Author, contact, bugs, mailing list and more

- Recommend me at <http://workingwithrails.com/person/5061-francesc-esplugas>
- Browse source on GitHub <http://github.com/fesplugas/typus/tree/master>
- Visit the wiki <http://github.com/fesplugas/typus/wikis>
- Group <http://groups.google.es/group/typus>
- Report bugs <http://github.com/fesplugas/typus/wikis/bugs>

Copyright (c) 2007-2008 Francesc Esplugas Marti, released under the 
MIT license