# Sovren

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sovren-ruby', path: 'PATH_TO_THE_GEM'
```

## Usage

TODO: Write usage instructions here

``` ruby
@resp = Sovren::Client.new(file,
  account_id: '32215752',
  service_key: 'zwbDwscb0qyc6RoZVeXybBYymzJvTtrA5mcuf6hM',
)
@resp.user_info
@resp.educations
@resp.employments
@resp.internships
@resp.all
@resp.to_xml
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
