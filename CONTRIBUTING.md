Hi,
Welcome to the contributing guide for the get.opensuse.org website. We are very eager to take any and all contributions from you, and to aid you in successfully contributing to this codebase.

* [About](#about)
  * [Where is the code hosted?](#where-is-the-code-hosted)
  * [What are the technologies used?](#what-are-the-technologies-used)
  * [Get in contact with us!](#get-in-contact-with-us)
  * [Submitting changes](#submitting-changes)
* [Reporting Bugs](#reporting-bugs)
  * [Fixing Bugs](#fixing-bugs)
* [Setting up the development environment](#setting-up-the-development-environment)
* [How to update the data on the site](#how-to-update-the-data-on-the-site)
  * [Releases](#releases)
  * [Distribution info](#distribution-info)

# About

## Where is the code hosted?
You can find the canonical git repository here: <https://github.com/openSUSE/get-o-o.git>

## What are the technologies used?
This is a [jekyll](https://jekyllrb.com/) based website, using the [openSUSE theme](https://github.com/openSUSE/jekyll-theme/). It is extended with a few plugins in </_plugins/>, which allows for an extended usage of jekyll.

## Get in contact with us!
We are available on various instant messaging platforms, as well as more traditional mailing list, use the links below to get in contact if you need or want to.

* Matrix: <https://matrix.to/#/#web:opensuse.org>
* Discord: <https://discord.gg/openSUSE>
* Mailing Lists: <https://lists.opensuse.org/archives/list/web@lists.opensuse.org/>

## Submitting changes
To submit changes for review, create a pull request on the [site's GitHub](https://github.com/openSUSE/get-o-o/), if your PR contains UI changes, please include a screenshot before and after, so that it's easier for us to review the changes.

# Reporting Bugs
Bugs in this repo need to be reported to the GitHub Issues on the GitHub repo.
You can do so here: https://github.com/openSUSE/get-o-o/issues/new

## Fixing Bugs
The link below lists all the currently reported bugs against the project on GitHub.
https://github.com/openSUSE/get-o-o/issues
Those bugs still need fixing and we would appreciate any pull requests fixing them.

# Setting up the development environment
You will need to install `git`, `ruby`, `gem` and `bundler` first, then, to gather the remaining dependencies, run:

```sh
git clone https://github.com/openSUSE/get-o-o.git
cd get-o-o
bundle config set path 'vendor/bundle'
bundle install
```

To build the site, run
```sh
bundle exec jekyll build
```

To serve the site on your local machine, run:
```sh
bundle exec jekyll serve
```
and visit <http://127.0.0.1:4000/> to see it in your browser

# How to update the data on the site
Various parts of this site are stored as data used for generation of pages. This section of the guide explains how to update those.

## Releases
Release information is stored in `_data/leap.yml` and `_data/leapmicro.yml`

To create a new release, add information on it, replacing the parts to fit the contents, and fill it out as lined out below:

```yaml
- version: # Version number
  order: # Order number (older should be lower)
  releases:
  - date: '2022-06-08 12:00:00 UTC' # Time of the release
    state: 'Stable' # Name of the state of the release
```

## Distribution info
Distribution information is stored in `_data/tumbleweed.yml`, `_data/microos.yml` and remaining versioned `.yml` files in `_data`.

```yaml
name: # Distribution name
bg-color: # Distribution css class
fg-color: # Distribution text/logo color
logo: logos/logo.svg # logo in _includes directory
choosing-media: # Include choosing media metadata
downloads:
- name: # Name of the download category
  display: all # ?type= url query link handling (all shows the category always, any other option only shows up when that option is in ?type= query option)
  arches:
  - name: x86_64 # Name of the arch category
    types:
    - name: # Name of the image
      desc: # Description of the image
      primary_link: # URL of the image
      links: # Additional URLs for the images
      - name: # Additional Name of the image
        url: # Additional URL of the image
```

## Thank you for considering contributing!
