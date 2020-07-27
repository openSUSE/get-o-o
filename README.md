# Get openSUSE
Website promoting the openSUSE distribution development effort, explaining what the distributions do, who they are for and link to useful places to get information about the distributions.

## How to build?

```bash
bundle install --path vendor/bundle
bundle exec rake
bundle exec jekyll build
```

Resulting site will be in `_site` directory.

## How to serve locally?

```bash
bundle install --path vendor/bundle
bundle exec rake
bundle exec jekyll serve
```

Visit <http://127.0.0.1:4000/> in your browser.
