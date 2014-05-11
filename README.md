# pushpop-recipes

A collection of common [Pushpop](https://github.com/keenlabs/pushpop) jobs and templates

### Usage

Copy files from this repository into your Pushpop projects. Here's an example of how to do this with git and cp.

**Clone this repository**

``` shell
git clone git@github.com:keenlabs/pushpop-recipes.git
```

**Copy into your Pushpop project**

``` shell
cp <recipe>/*.rb ../pushpop/jobs
cp <recipe>/*.erb ../pushpop/templates
```

This example assumes your `pushpop` folder is a sibling to `pushpop-recipes`.

### Current recipes

##### Pingpong

+ `response_time_report` - A job that sends a daily response time summary of HTTP checks performed by [Pingpong](https://github.com/pingpong/pingpong.git). Requires that environment variables for Keen IO and Sendgrid be set.

### Contributing

Contributions are very welcome – that's what this repository is for! Please use Github issues and pull requests to contribute.

##### Organization

Each related set of recipes should be grouped into its own folder. That folder can contain both job files and templates.

##### Guidelines

There are a few guidelines to follow to make sure your recipe is as useful as it can be for others:

+ Include explanation / documentation in comments or separate markdown files
+ Comment or label clearly variables that other users will need to change
+ Make sure no API keys or other sensitive information is used in the code
+ Specify exactly what environment variables need to be present for the recipe to work