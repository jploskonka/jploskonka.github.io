---
title: Rails on Heroku with Terraform
date: 2019-01-25
excerpt: Codifying Heroku config for Rails app with Terraform. How to do it and why should you care?
---


As simple as Heroku is in its configuration and as pleasant and comfortable
their UI is for clicking out different settings it's still clicking around web
browser to manage your infrastructure resources. It works very well if you need
to do it just once, you're working in really small team and your application
requirements are pretty simple and stable. Just login to Heroku dashboard, click
at bunch of links, fill few inputs and voila – your Dyno is backed up with
Database. Now just open your terminal, enter literally two or three more
commands, finish everything with `git push heroku master`, wait for nokogiri
to install native extensions and you're ready to show your app to the world!

# [TUTAJ GIF YEYEYEYEYEYE FUCK YEAH]

Not long after that you get customers using your app and you realise your database plan is
not enough anymore. You login to Heroku dashboard, increase database capacity.
Everything is perfect, your app works stable just until your new marketing
campaign brings thousands of new visitors. Fantastic, your dyno is out of
memory, quick login, upgrade dyno. Now you have visitors using your page so it's
not the best idea to test your features on production instance, so you login to
heroku dashboard, setup an app, throw some database, logging, dyno scaling, you
attach it to pipeline. Party time!

Next day you realise your database load is yet again skyrocketing, quick
investigation and shit... You forgot about caching! So you log in to heroku
dashboard, add redis instance to your production app, restart dyno, everything
works like a charm. Business is getting more and more profitable, you almost
have enough money to pay yourself salary so you hire another developer. He comes
in, develops feature, passes code review, tests on staging and app is super slow
there... What's wrong? Ah, yeah! Fuck! Someone forgot about adding redis
instance to staging app, there's no caching there! And it took only 4 hours to
realise that, because addons are listed in visible place, in big letter. Who'd
make mistake in adding those?

OK, time for visitors tracking, let's add some Google Analytics, mixpanel and
Ahoy tracking codes, with configuration stored in ENV variables, of course
different for every environment. So you log in to heroku dashboard... You get
the point...

# [GIF I don't want to live on this planet anymore]

## Ain't developers supposed to write code?
What if there was a way to make it all simpler. Why would any reasonable person
spend hours on clicking through staging environment configuration if there's
already production one ready? I mean, if staging is supposed to be as similar to
production as possible why can't I just take production config, scale down some
dynos and database, maybe remove some plugins, tweak ENV variables and deploy
this thing all together. Isn't this XXI century or something like this?

## Infrastructure as Code & Terraform.
```
Infrastructure as code (IaC) is the process of managing and provisioning
computer data centers through machine-readable definition files, rather than
physical hardware configuration or interactive configuration tools. The IT
infrastructure managed by this comprises both physical equipment such as
bare-metal servers as well as virtual machines and associated configuration
resources.
```
[Wikipedia - Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_code)


## Setting up
brew install terraform

### create production environment
start with terraform init
### staging environment
### adding database
### adding redis cache
### adding papertrail logging
### git first deployment, scaling dynos

### DRY up with terraform modules
### different dynos

### adding worker dyno [Sidekiq]

## Remote state

### Wrap up

<a style="background-color:black;color:white;text-decoration:none;padding:4px 6px;font-family:-apple-system, BlinkMacSystemFont, &quot;San Francisco&quot;, &quot;Helvetica Neue&quot;, Helvetica, Ubuntu, Roboto, Noto, &quot;Segoe UI&quot;, Arial, sans-serif;font-size:12px;font-weight:bold;line-height:1.2;display:inline-block;border-radius:3px" href="https://unsplash.com/@fancycrave?utm_medium=referral&amp;utm_campaign=photographer-credit&amp;utm_content=creditBadge" target="_blank" rel="noopener noreferrer" title="Download free do whatever you want high-resolution photos from Fancycrave"><span style="display:inline-block;padding:2px 3px"><svg xmlns="http://www.w3.org/2000/svg" style="height:12px;width:auto;position:relative;vertical-align:middle;top:-2px;fill:white" viewBox="0 0 32 32"><title>unsplash-logo</title><path d="M10 9V0h12v9H10zm12 5h10v18H0V14h10v9h12v-9z"></path></svg></span><span style="display:inline-block;padding:2px 3px">Fancycrave</span></a>
https://unsplash.com/photos/0E0j6aC5BUw
