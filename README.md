# Get openSUSE
Website promoting the openSUSE distribution development effort, explaining what the distributions do, who they are for and link to useful places to get information about the distributions.

## How to build?

Instructions assume openSUSE Tumbleweed base:

```bash
bundle config --local path vendor/bundle
bundle install
bundle exec rake
bundle exec jekyll build
```

Resulting site will be in `_site` directory.

## How to serve locally?

Instructions assume openSUSE Tumbleweed base:

```bash
bundle config --local path vendor/bundle
bundle install
bundle exec rake
bundle exec jekyll serve
```

Visit <http://127.0.0.1:4000/> in your browser.


## Configuring openSUSE releases

The file `_data/releases.yml` is used by the distributions to render the right template (`leap-$version`).
Please make sure that (`leap-$version`) has a corresponding template in `_data/`.

```yaml
---
- version: 42.3
  order: 2
  releases:
  - date: '2017-07-08 00:00:00'
    state: 'RC'
  - date: '2017-07-26 00:00:00'
    state: 'Stable'
  - date: '2019-07-01 00:00:00 UTC'
    state: 'EOL'
- version: 42.2
  order: 1
  releases:
  - date: '2016-11-16 00:00:00'
    state: 'Stable'
  - date: '2018-01-26 00:00:00 UTC'
    state: 'EOL'
- version: 42.1
  order: 0
  releases:
  - date: '2016-11-16 00:00:00'
    state: 'Stable'
  - date: '2017-01-17 00:00:00 UTC'
    state: 'EOL'
```
