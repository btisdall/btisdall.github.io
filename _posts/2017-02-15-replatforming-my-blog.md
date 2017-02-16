---
title: Re-homing my blog
date: 2017-02-19
tags: [ GitHub Pages, CloudFlare, Jekyll, Blogging, Calepin ]
---

Five years ago I thought I'd have a go at blogging. Let's not mince words here, I was bloody rubbish and I couldn't even use the excuse [that it was all too much of a palaver](../ive-run-out-of-reasons_not-to-blog).

Anyway, cut to 2017 and I'm having another go. Calepin is no more but that's OK because it no longer meets requirements which are now:

1. No setup or maintenance of a remote system.
2. Write posts in Markdown or something else that works well in a text editor (in my case Vim).
3. Store content in SCM.

I considered three options: Medium, Wordpress and GitHub Pages. In the end I decided that Medium was slick but I wanted something that would stand out as "mine", Wordpress involved some (1) if I wanted to go beyond a wordpress.com account plus it's all database-y leaving GitHub pages the winner. Of course GitHub Pages didn't simply win through on a knockout, they don't call Git ["the open source community's dearest-to-the-heart tool"](http://bryanpendleton.blogspot.de/2017/02/big-news-in-world-of-source-control.html) for nothing and of course GitHub builds on Git with a plethora of fantastic workflow features. And since a large part of the web relies on GitHub to keep working I can count on them trying really, really hard to be up all the time.

# TL;DR

[Secure and fast GitHub Pages with CloudFlare](https://blog.cloudflare.com/secure-and-fast-github-pages-with-cloudflare/).

# Setting up GitHub Pages

I assume familiarity with Git and GitHub here. The [GitHub Pages documentation](https://pages.github.com/) is pretty good and you'll get started in seconds. By default GitHub uses [Jekyll](https://jekyllrb.com/) under the hood which means that it takes care of rendering your site when you push or merge to the master (for user pages) branch.

## A quick try from scratch

1. Create an empty repo named `<USERNAME>.github.io` and on the master branch add a file named `index.md` with some Markdown like [this](https://gist.githubusercontent.com/btisdall/1a92648b87baca70075e0f2e9700d425/raw/16b7c750a2b579861986bc9f29ee67db6b3ee6a6/index.md).
2. Push the master branch up and view `https://<USERNAME>.github.io` — you should see your index page formatted as html.
3. By default GitHub pages will use the Jekyll `minima` theme. To change to another supported Jekyll theme visit the `Settings` page for the repo, scroll to the GitHub pages section and click `Theme chooser`. Notice that when you select a theme GitHub will add a line to the file `_config.yml` (creating it if necessary) and make a commit for you. Admire your new theme.

## Getting a bit more fancy

An important virtue in programming is laziness so let's not reinvent the wheel. Lots of people have done the hard work of providing scaffolding for Jekyll blogs, I picked one called [Jekyll Now](https://github.com/barryclark/jekyll-now) — thanks Barry Clark! Let's reset our experimental repo to use Jekyll Now _(it is an experimental repo, right? Otherwise don't use the following commands)_.

```
git checkout master
git remote add jekyllnow git@github.com:barryclark/jekyll-now.git
git fetch jekllnow
git reset --hard jekllnow/master
git push -f origin master
git remote remove jekyllnow
```

Although having GitHub pages render your site is convenient it's an unsatisfactory preview workflow. Installing the Jekyll gem will let you render and serve the blog locally for lightning fast previews (notice how Jekyll Now's `.gitignore` ignores `_site` because the generated site shouldn't be in SCM if you're using a GitHub-supported theme). I deviated from the instructions on the Jekyll Now site just a little as I like to use rbenv and Bundler — once I'd set these up and run `bundle` I added `.ruby-version`, `Gemfile` and `Gemfile.lock` to [my own repo](https://github.com/btisdall/btisdall.github.io).

To render and serve your pages locally (assuming you're using Bundler) run `bundle exec jeykll serve`:

```
$ bundle exec jekyll serve
Configuration file: /Users/bentis/me/btisdall.github.io/_config.yml
Configuration file: /Users/bentis/me/btisdall.github.io/_config.yml
            Source: /Users/bentis/me/btisdall.github.io
       Destination: /Users/bentis/me/btisdall.github.io/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
                    done in 0.507 seconds.
 Auto-regeneration: enabled for '/Users/bentis/me/btisdall.github.io'
Configuration file: /Users/bentis/me/btisdall.github.io/_config.yml
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.
```

Load [http://127.0.0.1:4000/](http://127.0.0.1:4000/) and there's your preview right there.

## Converting old Calepin posts

http://calepin.co used [Pelican](https://github.com/getpelican/pelican) behind the scenes. Pelican uses [this post format](http://docs.getpelican.com/en/stable/quickstart.html#create-an-article).

To switch the posts up to Jekyll format where the "front matter" is a YAML block and metadata field names have changed I ran:

```
cp /path/to/oldblog/*.md _posts/
ruby -pi -e 'BEGIN{doneheader=false};if $.==1; $_="---\n#{$_}";end; next if /^slug/i; if $_ =~ /^$/ && !doneheader; $_="---\n#{$_}"; doneheader=true; end; $_.gsub!(/^(Title|Date|Tags):/) { "#{$1.downcase}:" }; $_.gsub!(/(tags):\s+(.*)/) { "#{$1}: [ #{$2} ]" }; $_.gsub!(/^#(\w.*)/, "# \\1")' _posts/*.md
```

I also made some manual edits to code blocks because Calepin didn't support GitHub flavoured Markdown — it wasn't worth the effort of scripting this given the small number of posts.

## Setting up a custom hostname

GitHub pages supports a single custom hostname. Note that once set it will not only answer to the custom hostname but redirect requests to `<USERNAME>.github.io` to it too (which is not unreasonable behaviour but not what you might expect if you're used to working with virtual hosts). Anyway, setting up a custom name is as easy as:

```
echo mydomain.example.foo > CNAME
# git commit ...
```

## HTTPS with the standard hostname

`https://<USERNAME>.github.io` just works and you can mandate https by visiting `Repo Settings -> GitHib Pages -> Enforce HTTPS` but note that this option isn't available with a custom hostname since GitHub doesn't offer TLS termination for these.

## HTTPS with a custom hostname — CloudFlare to the rescue

### Account setup

Using CloudFlare's free tier you can terminate https with them redirect http requests to https, cache your site(s) and other nifty stuff.

Once you've [created an account](https://support.cloudflare.com/hc/en-us/articles/201720164-Step-2-Create-a-CloudFlare-account-and-add-a-website) you'll need to import your DNS records — CloudFlare will scan your domain for standard hostnames like `www`, MX records and so on and add these but you'll probably need to import some records manually. When you're done importing records switch up the nameservers for your domain using your domain name registrar's control panel or whatever. I won't elaborate further on this since the CloudFlare article explains things well.

### GitHub Pages setup

To set things up with GitHub Pages up I followed [this article](#tldr) which again does a great job of guiding you through the process.

### Browser TLS support with CloudFlare free tier

There's one small caveat with the free tier in that for reasons of economy the TLS termination relies on the user agent being [SNI](https://en.wikipedia.org/wiki/Server_Name_Indication) compliant — to do otherwise would require a scarce IPv4 address for each customer domain. If your audience can reasonably be expected to be using a "modern" browser then SNI compliance [shouldn't be a problem](https://www.digicert.com/ssl-support/apache-secure-multiple-sites-sni.htm) but if it's vital for your website to have the widest possible browser compatibility (IE on Windows XP anyone?) then either use a paid for CloudFlare account or another solution.

# Conclusion

So far GitHub Pages seems like a great Calepin replacement for static website hosting and CloudFlare makes it easy to keep everything https with a custom hostname while also adding features like caching. There are a few TODO items like getting tags working, tweaking code block appearance to my liking and resurrecting the old Disqus comments, I'll write about these when I get round to them.
