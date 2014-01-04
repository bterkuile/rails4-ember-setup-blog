Since the online resources considering the right way of combining a rails app with Ember here a short example of a Rails 4 Ember setup that scales. The basic examples provided online are set up to be single issue, do not consider a full stack Rails application with parts handled by Ember, since Ember is a nice framework. Since my time is short I will try to update this post to eventually get it to give the optimal amount of information.

<b>DISCLAIMER: this is a very hasty blog post, just to indicate a setup, not
a complete application. Visit the [github](https://github.com/bterkuile/rails4-ember-setup-blog) page for the code.
If you happen to be on the github page and want to visit the blog page
go to the [blog](http://bterkuile.tumblr.com/post/72196495361/rails4-and-ember-synergy-setup-blogger-start)
</b>

First we build our basic application call Blogger:

<pre>
rails new Blogger
mv Blogger blogger
cd blogger
</pre>

Then edit the Gemfile to include dependencies:

<pre>
source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.2'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Add Ember stuff
gem 'ember-source'
gem 'ember-rails'
gem 'slim-rails'

group :assets do
  # Use SCSS for stylesheets
  gem 'sass-rails', '~> 4.0.0'

  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier', '>= 1.3.0'

  # Use CoffeeScript for .js.coffee assets and views
  gem 'coffee-rails', '~> 4.0.0'

  # Add Ember stuff
  gem 'emblem-rails'
end

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
#gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
</pre>

Since there are some ideas in Ruby on Rails that used to be a good idea,
some are not. One of them is indicated by the rule: <strong>Never use
require_tree . in the main application manifest!!!</strong>.

So your <tt>app/assets/javascripts/application.js</tt> now should look
like:

<pre>
//= require jquery
//= require jquery_ujs
//= require_directory .
</pre>

Note that the turbolinks gem is removed. This should be a well considered
discission, not a default.

Now create the ember install:
<pre>
rails generate ember:install
</pre>
Do not use the bootstrap generator since we are discussing a customized
approach overhere. The structure of this generator however is a good one
so we are keep this directory structure, but in a different directory.

Set a proper environent in <tt>config/environements/development.rb</tt>
to get the correct template root without namespace:
<pre>
  ...
  config.ember.variant = :development 
  ...
</pre>

Since we are using a namespaced Rails asset pipepline (Blog post about
this not yet written), we will place the ember app specific files in the
namespace <tt>app/assets/javascripts/ember\_app</tt>. So first we will
create our Ember app manifest file
<tt>app/assets/javascripts/ember_app/application.js.coffee</tt>:

<pre>
#= require handlebars
#= require ember
#= require ember-data
#= require_directory ./modifications
#= require ./app
#= require_tree .
</pre>

And the directory structure:
<pre>
cd app/assets/javascripts/ember_app
mkdir modifications
mkdir views
mkdir models
mkdir routes
mkdir templates
touch app.js.coffee
touch store.js.coffee
touch routes.js.coffee
</pre>

<pre>
rails g scaffold Post title:string body:text
rails g scaffold Comment email:string body:text post_id:integer
rake db:migrate
rails g controller Dashboard home
</pre>

Set the root and nested basic routes in <tt>config/routes.rb</tt>:
<pre>
Blogger::Application.routes.draw do
  resources :posts do
    resources :comments
  end
  root 'dashboard#home'
end
</pre>

Now set <tt>app/views/dashboard/home.html.slim</tt> to:

```
  #ember-app-container
```

And add the ember app to the
<tt>app/views/layouts/application.html.slim</tt>:
<pre>
doctype html
html
  head
    title Blogger
    = stylesheet_link_tag    "application", media: "all"
    = javascript_include_tag "application"
    = javascript_include_tag "ember_app/application"
    = csrf_meta_tags
  body= yield
</pre>

Now setup the ember application. First define the App root. This can be
namespaced, but for simplicity we take the root here
<tt>app/assets/javascripts/ember_app/app.js.coffee</tt>:
<pre>
@App = Ember.Application.create
  LOG_TRANSITIONS: true
  rootElement: '#ember-app-container'
</pre>

Now create the store to mimic the rails structure with nested routes in
<tt>app/assets/javascripts/ember_app/routes.js.coffee</tt>:

<pre>
App.Router.reopen
  location: 'history'

App.Router.map ->
  @resource 'posts', ->
    @resource 'post', path: ':post_id'
</pre>

Now we are gonna setup some basic templates.
<tt>app/assets/javascripts/ember_app/templates/application.hbs</tt>:
<pre>
{{outlet}}
</pre>

<tt>app/assets/javascript/ember_app/templates/index.emblem</tt>
<pre>
.posts-container
  each post in controller.posts
    ' {{view 'App.PostView' contextBinding=post}}
</pre>

<tt>app/assets/javascript/ember_app/templates/post.emblem</tt>:
<pre>
h3
  link-to "post" this
    ' {{title}}
p {{body}}
</pre>

<tt>app/assets/javascript/ember_app/views/post_view.js.coffee</tt>:
<pre>
App.PostView = Ember.View.extend
  templateName: 'post'
  classNames: ['post-container']

</pre>

Setup the store to be ready for active_model
<tt>app/assets/javascripts/ember_app/store.js.coffee</tt>:
<pre>
  # http://emberjs.com/guides/models/defining-a-store/
  # uncomment the following to add a namespace to the requests
  #DS.RESTAdapter.reopen
  #  namespace: 'api'

App.ApplicationSerializer = DS.ActiveModelSerializer
App.Store = DS.Store.extend
  adapter: DS.RESTAdapter
</pre>

And tell the IndexRoute to fetch the blog posts
<tt>app/assets/javascripts/ember_app/routes/index_route.js.coffee</tt>:
<pre>
App.IndexRoute = Ember.Route.extend
  model: (params, queryParams)->
    Ember.Object.create
      posts: @store.find 'post'
</pre>

And create the model
<tt>app/assets/javascripts/ember_app/models/post.js.coffee</tt>:
<pre>
App.Post = DS.Model.extend
  title: DS.attr('string')
  body: DS.attr('string')
</pre>

Now the basics work. This app is far from finished, but now we have a
hybrid rails/ember setup we can expand by using either rails or ember
goodies.
