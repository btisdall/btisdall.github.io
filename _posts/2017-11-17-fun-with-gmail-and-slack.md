---
title: Fun with Gmail and Slack
date: 2017-11-17
tags:
  - Gmail
  - Email
  - Slack
---

This is brief article describing a productivity tip (for you young folk out there a "life hack") that lets you use Slack to notify you about emails of particular interest.

# One notification system to rule them all

Well, fewer anyway. Like many people I far prefer IM over email and I'm fortunate enough to work in a place where if someone needs to have a conversation with me they'll almost certainly use IM or come over to my desk. Perhaps as a consequence of this is that I've become less good at paying attention to email, which can sometimes cause problems (of course email clients can notify you about incoming mail, but it's often not that configurable and I would prefer to have as few systems for telling me about stuff as possible).

# Slack email addresses

If you're a member of Slack team just head over to `Preferences -> Messages & Media`, scroll down to `Bring Emails into Slack` and hit `Get a Forwarding Address`. There's a handy `Copy` button but it copies the address in `DISPLAY NAME <address@domain>` form which you don't want for pasting into Gmail so you might just want to copy it yourself.

# Gmail forwarding addresses

Setting up a forwarding address is pretty easy, if you want a walk-through try this [Google help article](https://support.google.com/mail/answer/10957?hl=en). Once you've completed the process Gmail will send a verification email to the address and Slackbot should tell you it's received it - expand the message, click on the confirmation link and congratulations, you're done preparing.

# Doing something useful

Emails that I really don't want to miss include GitHub PR review requests and meeting invites and, while you might have an "if a quick response is important they'll Slack me or visit me in real life" rule in your head there are probably senders that you don't want to apply that to.

Here's how to set up the GitHub rule in Gmail:

* Go to `Settings -> Filters and Blocked Addresses` and click on `Create a new filter `.
* In `From` set the sender address, in this case `notifications@github.com`.
* In the `Has the words` box enter `requested your review on:`, then click the `continue >>` link in the bottom RH corner of the filter window.
* On the next screen check `Forward it to` and select your Slack email address from the drop down.
* Click `Create Filter` and you're done.

For a more graphical guide to setting up forwarding filters try [this lifewire article](https://www.lifewire.com/how-to-forward-gmail-email-using-filters-1171934). Obviously you have a lot of flexibility as to the filtering criteria.



 
