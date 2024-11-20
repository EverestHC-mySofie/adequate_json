# AdequateJSON

AdequateJSON is a serialization gem for Ruby on Rails APIs. It is easy to use, versatile,
[fast](#performances), and promotes API best practices.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'adequate_json'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install adequate_json

## Usage

If you'd like to tinker with AdequateJSON on your own, see the
[sample Rails API](https://github.com/EverestHC-mySofie/adequate_json_sample).

### At the controller level

If you're using — and you probably are — a controller inheriting `ActionController::API`,
AdequateJSON adds a `render_json` method to controllers, to which you can provide a model
instance, or a collection of models:

```ruby
class CategoriesController < ActionController::API
  def index
    render_json Category.order(:name)
  end

  def show
    render_json Category.find(params[:id])
  end
end
```

AdequateJSON automatically infers the type of serializer it should use
based on the model type, see the [next section](#your-first-serializer).

### Your first serializer

When rendering a model, AdequateJSON searches for the corresponding serializing
class in the `Serializers` module (or the module you specify using the
[configuration](#configuration)).

Each serializer is a class extending `AdequateJSON::Base`, and defining one or several
variants to build (defaulting to `:default` for single objects and `:no_wrapper`
for collections):

```ruby
# app/serializers/category.rb

class Serializers::Category < AdequateJSON::Base
  builder do |json, category| # Same as builder(:default)
    json.category do
      json.(category, :id, :name, :created_at, :updated_at)
    end
  end

  builder(:no_wrapper) do |json, category|
    json.(category, :id, :name)
  end
end
```

AdequateJSON is based on Jbuilder. For all JSON manipulation methods available,
have a look at [Jbuilder's DSL documentation](https://github.com/rails/jbuilder).

### Choosing a variant

Builder variants default to `:default` for single objects, and `:no_wrapper` for
collection items. To use another variant, specify it as a keyword argument:

```ruby
class ProductsController < ActionController::API
  def index
    render_json Product.order(:name), variant: :header
  end

  def show
    render_json Product.find(params[:id]), variant: :full
  end
end
```

### Reuse and composition

Each variant can be reused inside other variant using the `serialize` helper
method, that runs on the same JSON builder. This allows for reuse of builders
as partials, or make a variant "inherit" another one:

```ruby
class Serializers::Product < AdequateJSON::Base
  builder do |json, product| # Same as builder(:default)
    json.product do
      serialize product, variant: :no_wrapper
    end
  end

  builder(:full) do |json, product|
    json.product do
      serialize product, variant: :no_wrapper
      serialize product.colors
      serialize product.sizes
      serialize product.category
    end
  end

  builder(:no_wrapper) do |json, product|
    serialize product, variant: :header
    json.(product, :description, :created_at, :updated_at)
  end

  builder(:header) do |json, product|
    json.(product, :id, :name, :price)
    serialize product.category
  end
end
```

### Supported source objects

AdequateJSON uses built-in serializers for hashes and collections and,
when serializing objects, will use the `#model_name` property to retrieve
the name of the serializer to search for.

If you need to change the type of serializer for a given model, you may define
the `serializer` method on the model:

```ruby
class Book < ApplicationRecord
  # ...

  def serializer = :product
end
```

In last resort, you may also specify explicitely the serializer class to use:

```ruby
render_json Serializers::Product.new(Book.find(params[:id])).to_builder
```

### Serializing multiple objects at once

To serialize more complex structures, simply use a hash:

```ruby
class ProductsController < ActionController::API
  def show
    render_json { product: Product.find(params[:id]), categories: Category.order(:name) }
  end
end
```

### Pagination

As soon as you've added [Kaminari](https://github.com/kaminari/kaminari)
to your Gemfile and paginate a collection, AdequateJSON automatically appends
the `pagination` property to the JSON output:

```ruby
class ProductsController < ActionController::API
  def index
    render_json Product.order(:name).page(params[:page]).per(10)
  end
end
```

```
{
  "collection": [
    {
      "id": "a9342787-0d24-43cf-8791-3a512f9e9bd4",
      ...
    },
    ...
  ],
  "pagination": {
    "current_page": 1,
    "total_count": 289,
    "next_page": 2,
    "previous_page": null,
    "total_pages": 29,
  }
}
```

If you'd like AdequateJSON to support other pagination gems, feel
free to craft a pull-request or to open an
[issue](https://github.com/EverestHC-mySofie/adequate_json/issues),
we'd be glad to help.

### Rendering errors

Specify an error code, and AdequateJSON will try to localize it
with a message found in one of your `locales/*.yml` files. The i18n
scope defaults to `api.errors`, you may change it in the
[configuration](#configuration). It also automatically renders errors
based on ActiveModel messages.

```ruby
class ProductsController < ApplicationController
  # ...

  def create
    product = Product.new(product_params)
    if product.save
      render_json product
    else
      render_error :invalid_model, product
    end
  end
end
```

Given a locale key `api.errors.invalid_model`, the `render_error`
call would produce:

```json
{
  "error": {
    "code": "invalid_model",
    "message": "The object couldn't be saved",
    "details": {
      "category": [
        "must exist"
      ],
      "name": [
        "can't be blank"
      ],
      "description": [
        "can't be blank"
      ],
      "price": [
        "can't be blank",
        "is not a number"
      ]
    }
  }
}
```

If you need to return errors for nested models and attributes,
you may use the `includes` keyword argument:

```ruby
render_error :invalid_model, product, includes: { category: :shop }
```

### Configuration

All configuration options are available through a block yielded by
the `AdequateJSON.configure` method.

The configuration code should take place in the `application.rb` file
or one of the Rails environment configurations (`production.rb`,
`development.rb`, etc.), not in an initializer:

```ruby
module AdequateJsonSample
  class Application < Rails::Application

    AdequateJson.configure do |c|
      c.serializers_module :json # defaults to :serializers
      c.use_model_name_for_collection_key true  # defaults to `false`
      c.collection_key :list # defaults to `collection`
      c.i18n_errors_scope %i[controllers error] # defaults to `%i[api errors]`
    end
end
```

## Performances

We've written a small benchmark to see how AdequateJSON performs compared
to [ActiveModelSerializers](https://github.com/rails-api/active_model_serializers).
The benchmark consists in serializing 10 times a collection of 10 000 objects
(the lower the better) and displaying the min, max and average processing times:

```
$ bundle e ruby benchmark.rb
AdequateJSON - min: 75.68, max: 95.1 - average: 81.5 ms
ActiveModelSerializers - min: 471.04, max: 582.73 - average: 491.63 ms
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/EverestHC-mySofie/adequate_json.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
