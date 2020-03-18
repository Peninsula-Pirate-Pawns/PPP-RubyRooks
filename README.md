# Peninsula Pirate Pawns

![Peninsula Pirate Pawns](https://i.imgur.com/UGOaEbT.png)

This web application is a simple game of chess with a pirate theme. Our Agile team members all resided in Florida at the time we came together to make this project so we found it fitting to have an ocean related theme. Make an account, join or create a game and flex your strategic thinking muscles!

## Features
- Personal account creation (sign in with Facebook, Twitter, Google, or simply create an account).<br />
- Two player games<br />
- Drag and drop pieces<br />
- Surrender a game<br />
- Supports Castling<br />
- Supports En Passant<br />
- Supports Pawn Promotion<br />

## Installation

Made with `Ruby 2.5.3` and `Rails ~> 5.2.3`<br />
Dependencies managed with `Bundler version 1.17.3`

Run:
```bash
bundle install
```
..to install dependencies. 

Then run the following commands to build the database:

```bash
rake db:create
rake db:schema:load
```

### Running the tests

We chose [Rspec](https://rspec.info/) to build out our test suite.<br />
`bundle exec rspec` - will run all specs(tests) for the project. 

## Gem highlights

### Devise

This project uses Devise for user registration, authentication, and validation. You can read more about Devise on their [github.](https://github.com/heartcombo/devise)

### Omniauth

The sign-in page relies on omniauth for users to create an account or sign in to an existing account via a third party. You will need to get your own API credentials from each company (Facebook, Google, Twitter) and set them in an `environment variable` for your version of this project to allow third-party authentication. 

## License
[MIT](https://choosealicense.com/licenses/mit/)
