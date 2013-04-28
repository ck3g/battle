# Battle
[![Build Status](https://travis-ci.org/ck3g/battle.png?branch=master)](https://travis-ci.org/ck3g/battle)
[![Code Climate](https://codeclimate.com/github/ck3g/battle.png)](https://codeclimate.com/github/ck3g/battle)

This gem is extraction from my [Battle45](https://github.com/ck3g/battle45) project

## Installation

Add this line to your application's Gemfile:

    gem 'battle'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install battle

## Usage

    # init the game
    game = Battle::Game.new 'name', 'email@example.com'
    # register your game and get game ID
    game.register!

    # Fight till victory
    game.nuke 0, 0 # don't forget to change coordinates

## Contributing

I'm sorry but contribution aren't allowed here.
It's [developer challenge](http://battle.platform45.com/) you should develop it by yourself.
