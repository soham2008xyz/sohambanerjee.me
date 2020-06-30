---
layout: post
title: "CloudBleed, and how you are impacted"
date: 2017-02-27 11:03:35
categories:
tags: security technology
image: /assets/article_images/2017-02-27-cloudbleed/taylor-vick-M5tzZtFCOfs-unsplash.jpg
image2: /assets/article_images/2017-02-27-cloudbleed/taylor-vick-M5tzZtFCOfs-unsplash.jpg
---
The latest story doing the rounds on Hacker News is how Cloudflare, one of the leading edge CDN providers, was susceptible to a vulnerability that dumped a massive amount of user credentials and other private data onto publicly accessible search engines. According to the same story, this vulnerability was first picked up by security analysts at [Google's Project Zero](https://googleprojectzero.blogspot.com/) team and reported to CloudFlare, who worked on deploying a rapid fix to issue. What has been adding to the confusion, however, is [this blog post by Cloudflare](https://blog.cloudflare.com/incident-report-on-memory-leak-caused-by-cloudflare-parser-bug/) where they seriously downplay both the extent of the problem, as well as the number of users actually affected by this bug.

So, is all well in CDN-land? Apparently not - for the same security researcher who reported the vulnerability has now released some redacted snapshots of the data dumped due to the vulnerability, post the expiry of the vulnerability notification window - and some pretty damning evidence comes to light. We see live ride details of an Uber driver (including OAuth credentials) using the Uber app on an iPhone, a person's fitness records on FitBit, and a chat log on the dating site OkCupid. All of these, as well as some SSL private keys, were dumped in plain-text. While Cloudflare has since fixed the vulnerability, what is even more worrying is that the fact the dumped data has been in many cases surreptitiously cached by search engines.

With Cloudflare confirming that no usernames or passwords have been directly leaked, the greatest impact of CloudBleed is how it has pointed out that users, in spite of having secure passwords and 2-factor authentication enabled, can be vulnerable to data breaches due to unforeseen bugs. On the bright side, Cloudflare has been very proactive in patching the bug once it was identified, so we have to now wait and see out the whole saga of CloudBleed plays out in the longer run.
