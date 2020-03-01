## Intro

Quick and dirty script of version control system working with Git. Basically, checks if given website has public or readable `.git` directory. Given a mass link of input data, crawls and extract possible Git directories.

## Hot, but how

Simply, by checking `.git/config` and `.git/HEAD`. In any case, match the output body and response code.

* `.git/config`
  - Shall return 200 OK, and match body `[core]`
* `.git/HEAD`
  - Shall return 200 OK, and match body `refs/heads` 

If any of these two is confirmed, the webdomain has accesable public listing of vcs directory. Later on we can use `GitDumper` to extract and exfill those data.

## The end

`btw, written in Crystal <3`
