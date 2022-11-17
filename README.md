<div align="center">
  <img alt="gem logo" src="/docs/lego.png">
</div>

## IP Shield
##### _A simple Roda plugin that helps you secure your Roda application by only allowing authoriased IP addresses an access to your app/page/resources_


Thank you for using `ip_shield` gem. This gem helps defending your Roda application agenst unwanted requests by only granding authorased IP addresses and access to the app, page or any resources.  


| 🏁  Installation & Getting statrted |
| ----------------------------------------- |


Install the gem and add to the application's Gemfile by executing:

    $ bundle add ip_shield

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install ip_shield


| 👔 Usage and examples |
| ----------------------------------------- |

Add the plugin to your Roda Application
```ruby
plugin :ip_shield, '0.0.0.0', ['128.0.0.0', '128.0.0.5']
```

Check if the request IP is authorised by calling `authorised_ip?` or `must_be_authorised_ip`. Please bear in mind that `authorised_ip?` will return a boolean value. `must_be_authorised_ip` in on the other hand will raise `UnauthorisedIP` error.
```ruby
route do |r|
  r.authorised_ip? ? 'IP is authorised' : 'IP is not authorised'
end
```

```ruby
route do |r|
    begin
        r.must_be_authorised_ip
        'IP is authorised'
        rescue UnauthorisedIP
        'IP is not authorised'
    end
end
```

You can add an IP from the request by simply using `authorise_ip`
```ruby
route do |r|
  r.authorise_ip unless r.authorised_ip?
end
```

Use `deauthorise_ip` to remove the de-authorise the request IP
```ruby
route do |r|
  r.deauthorise_ip if r.authorised_ip?
end
```

Note that calling `authorised_ip?` is not a must. However checking if the IP is authorised will help in preventing you from having a duplicate IPs, or de-authorise an IP that does not exist in the authorised IP list.


| 🛠 Development |
| ----------------------------------------- |


After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

| 📃 License |
| ----------------------------------------- |

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


