```
                               _           _
                              | |         | |
 _ __ ___   ___  ___  ___  ___| |__  _   _| |__
| '_ ` _ \ / _ \/ __|/ _ \/ __| '_ \| | | | '_ \
| | | | | |  __/\__ \ (_) \__ \ | | | |_| | |_) |
|_| |_| |_|\___||___/\___/|___/_| |_|\__,_|_.__/

```

## Getting Started

### Prerequisites
Ruby 1.9.3-p484 (this is the version used in productiion). Please see the section below if you need help getting this set up.

### Running mesoshub

Run mesoshub with marathon url and zookeeper hosts
Usage:

      shell> bin/mesoshub --haproxyfqdn proxy.domain --marathon http://master1.domain:8080 --zookeeper master1.domain:2181,master2.domain:2181,master3.domain:2181

### Setting up Ruby
If you use [rbenv](http://rbenv.org/), then update that, and [ruby-build](https://github.com/sstephenson/ruby-build) to their latest versions. With [homebrew](http://brew.sh/) that would be:

    shell> brew update && brew install rbenv && brew install ruby-build
    --OR, if they're already installed--
    shell> brew update && brew upgrade rbenv && brew upgrade ruby-build

Then, to install Ruby 1.9.3-p484:

    shell> rbenv install 1.9.3-p484

Then, to install dependencies:

    shell> gem install bundler
    shell> cd mesoshub
    shell> bundle install
    shell> rbenv rehash

Now you can run mesoshub using the instructions above.


#### Contributing to mesoshub

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

#### Contributors

Mesoshub was written by the team at Opentable, with contributions from the community.

* [Pablo Delgado](https://github.com/pablete)
* [Steven Schlansker](https://github.com/stevenschlansker)
* [Sam Salisbury](https://github.com/samsalisbury)
