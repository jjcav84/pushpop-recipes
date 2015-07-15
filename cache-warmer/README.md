# Sample Jobs to Warm up your Keen Queries on a Cold Night

Keen supports [query caching](https://keen.io/docs/api/#query-caching), which can really speed up your dashboards or other pieces of code that rely on query results. This job should help you set up a periodic job that will run the query every four hours so that the query is always cached when you need to use it.

### Dependencies

- [Pushpop-keen Gem](https://github.com/pushpop-project/pushpop-keen) version 0.3 or higher.
- Keen environment variables, see Pushpop-keen gem documentation for info.

### Setup

Copy the `cache_warmer_job.rb` file into your own jobs folder, then modify the query you want to run.

That's it! You can set up multiple jobs for each query, or one job for all the queries you want to set up.
