---
layout: post
title: "On ownership"
date: 2026-07-08 09:42:00
categories:
tags: featured startups engineering leadership
image: /assets/article_images/2026-07-08-on-ownership/post-bg.jpg
image2: /assets/article_images/2026-07-08-on-ownership/post-bg2.jpg
excerpt: >
  "Can you own this?" is a question I ask my team more often than almost any other. But I realized recently that I use the word "ownership" constantly without ever really unpacking what it means to me. So here it is - what I actually expect when I ask someone to own something, and why, in a small team building for real clients, there is no one else who is going to think about it if you don't.
---
I say the word "ownership" a lot. To my team, to new hires, in one-on-ones, probably in half my Slack messages. But it struck me recently that I use it constantly without ever really explaining what it means to me. So, ownership. When I ask "can you own this?" or "are you on it?" - I'm not asking you to write the code. I'm asking you to own the *solution* to a problem, end to end. From "we have a problem" to "we never have to think about this again."

That's a much bigger ask than it sounds. Here's what it actually means, in practice.

**Think about what the problem actually is.** It is very easy to walk in with a solution already in your head - "we need to migrate from X to Y" - without ever asking what we are actually trying to solve. That's not a problem, that's a solution wearing a disguise. The real problem is usually something like "this is slow," "this breaks for one specific client," "this isn't stable under load." Once you have the real problem, there are usually several ways to solve it. What are the tradeoffs? Given those tradeoffs, what's actually the best call?

**Think about the edges.** What are the edge cases here? Which ones matter, and which ones are we consciously choosing to ignore for now?

**Think about failure.** Networks fail. APIs time out. Third-party services go down at 2am. How do we handle that - retry? How many times, and with what backoff?

**Think about the data.** How much of it is there? Does anything need to be migrated or cleaned up first? What assumptions am I making about the shape of this data that I haven't actually verified?

**Think about how you'd know it's correct.** Are automated tests enough, or do you need to manually poke at it? Can you show the difference in a screenshot or a short recording?

**Think about the rollout.** How do we communicate this - to the team, to the client? Where does it sit in the bigger roadmap? If something about it worries you, push back. Ask. Now is the time, not after it's shipped.

**Do the work like you mean it.** With precision, with a sense of urgency, and without half-assing it because the deadline is close. Before you consider something done, ask yourself honestly - am I proud of this? Would I be comfortable explaining exactly what I built, under what constraints, with what tradeoffs, to someone whose engineering judgment I deeply respect?

**Test it yourself.** Not just the automated suite - actually run it. Poke at the data before and after. Take a screenshot. Record a quick demo. Convince yourself, not just the CI pipeline, that this actually solves the problem.

**Confirm it's live, and that it works live.** Deployed isn't the same as working. Is the feature flag on? Does it behave correctly in production, with real data, for a real client?

**Tell the people who need to know.** If this changes a convention in the codebase, or introduces something everyone should be aware of, say so. Don't underestimate peripheral vision - someone quietly knowing that you changed how a shared component behaves yesterday can save someone else three hours of confused debugging today.

**Tell the client, if it affects them.** Who reported this? Who was blocked by it? Let them know it's resolved.

**Follow up.** Check the logs a few days later. Did it actually hold up, or did something quietly regress?

That's a lot. And honestly, I'm sure I'm still forgetting a few things.

But this is what it takes to build for clients as a small team. At Renderbit, we don't have a dedicated QA department sitting between us and production, and most of our engineers work directly with clients rather than through a layer of product managers translating requirements back and forth. That's not a gap to apologize for - it's the model. It means everyone on the team has to genuinely own the full arc of a problem, not just the part that shows up in their ticket.

And to be clear, owning something doesn't mean going it alone. It's always okay to ask for help, to ask "dumb" questions, to redo something twice because the first version didn't sit right with you. What's not okay is quietly assuming someone else has already thought about the part you didn't feel like thinking about.

That's ownership, at least as I mean it. It's a lot to ask of people. It's also, I think, the only way a small team ever builds something a much bigger team would be proud of.
