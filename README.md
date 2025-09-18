# FatModelFinder

Whats the only kind of Model a Ruby Developer can get?

A Fat one...

FatModelFinder is a CLI tool designed to help developers identify "fat models" in their Rails applications. It scans the `/app/models` directory, analyzes each model file, and determines whether the model is "fat" based on conditions defined in this gem.

## Installation

To install the gem and add it to your application's Gemfile, execute:

    $ bundle add fat_model_finder

If Bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install fat_model_finder

## Usage

After installing the gem, you can use the CLI tool to scan your Rails application's models. Navigate to the root directory of your Rails application and run:

1. To scan the models and save the fat model data into a JSON file named `file_data`:

    ```bash
    fat_model_finder scan
    ```

2. To display the fat models based on the saved JSON data:

    ```bash
    fat_model_finder show_fat_models
    ```

The `scan` command analyzes the models in the `/app/models` directory and saves the results in a JSON file. The `show_fat_models` command parses the JSON file and outputs the fat model data to the user.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).