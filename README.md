# Transifex and Github integration via CI tool

This repository has an example on how you can configure a CI tool to leverage
the transifex-client CLI to exchange translation files between Transifex
and a Github repo.


## Basic Workflow

The setup for this particular example is based on a git flow, where you have a
`devel` branch which developers branch off to develop new stuff. Once the code
is ready, their work is merged to `devel`, which then triggers the translation
process. This workflow has the advantage that the translation process never
blocks deployment of code, however it's fair to call out that features may go to
production with missing translations, if there is no enough time for translators
to actually get their work done.

There are basically 2 operations that need to happen when you want to make your
development process to support localization in a seamless way with the workflow
above:

1. Pushing source content for translations whenever `devel` changes
2. Pulling translation files to ship features as translations are done


### 1. Pushing source content for translations whenever `devel` changes

The whole idea here is to push source content for translations immediately
after developers are ready with their work. You can make the CI tool to push
source files to Transifex in every build on `devel`. That way the state of
files in `devel` is mirrored in Transifex and translations can start as soon as
a merge happens.

Transifex can take care of updates to your source file automatically. As an
example, let's say you have a version of a source file with 10 strings, and all
languages you are targeting have them translated. If you update the source file
with 5 new strings, so that you have 15 in total, only the 5 new ones will need
to be translated.


### 2. Pulling translation files to ship features as translations are done

There are 3 scenarios you may want to consider for pulling translations.


#### a) Pulling just before you deploy/package your code

This is the most straight forward case. In your packaging/deployment process,
there is just one extra step needed, which grabs all fresh translation files (tx
pull) before you ship your code. Typically Transifex is the source of truth for
the translation files and they don't even get stored in the repo at all.


#### b) Pulling periodically and commit to your repo

This is a use case that requires some scripting on your side for a task that
will run every X amount of hours, commit the changes and push it back to the
remote repo. This case avoids any changes in the deploy process already in
place, because the translated files will be already available in the repo. One
thing to keep in mind is that translation files may not be alway reflecting the
latest changes in Transifex, as new translations can happen, since the last
periodically pull.


#### c) Pulling based on webhooks

Transifex can ping a webhook endpoint with specific info on translation
completion. Then you can trigger similar action as described in bullets a. and
b.


The setup in this repo has basically a. implemented with support to committing
translations back to the repo, just for the sake of having a full example. The
setup relies on git tagging system and basically listens to a tag called
`txpull`, which will trigger a fresh pull of translation files from Transifex
and commit any changes to the repository automatically. The setup emulates
the behavior applied for a deployment process triggered by git tags.


## Files in this repo

There are a few files in this repo that are required for it to work. Below you can find a bit more details about them.

```
locale/*.po

  This is where source content and translations files are stored in the repo.

.tx/config

  Configuration file used by transifex-client CLI tool for mapping files under
  `locale/` with a project in Transifex. Some more info can be found at
  https://docs.transifex.com/client/client-configuration#-tx/config

.travis.yml

  Travis CI configuration with support for running transifex-client CLI tool for
  push source content whenever `devel` changes and pulling translations files
  whenever a `txpull` tag is pushed.

tx.sh

  Helper script with checks and actions that can be taken based on environment
  variables and arguments passed to it.

```
