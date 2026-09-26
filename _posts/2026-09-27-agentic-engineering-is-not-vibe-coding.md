---
layout: post
title: "Agentic Engineering Is Not Vibe Coding"
date: 2026-09-27 03:45:00 +0530
categories:
tags: featured engineering ai agentic-engineering
image: /assets/article_images/2026-09-27-agentic-engineering-is-not-vibe-coding/hero.svg
image2: /assets/article_images/2026-09-27-agentic-engineering-is-not-vibe-coding/hero-mobile.svg
social_image: /assets/article_images/2026-09-27-agentic-engineering-is-not-vibe-coding/hero-social.png
excerpt: >
  AI can write a feature in minutes. That does not mean it can own the result.
  The difference between vibe coding and agentic engineering is not which
  model you use, but how you make decisions, verify the work, and take
  responsibility for what ships.
---

Show me an app built in an afternoon with a coding agent, and I'll probably be impressed. Ask me whether I'd put it in front of a client, with real users, real data, and someone calling us when it fails, and I'll have a rather different set of questions.

We've started using *vibe coding* as a catch-all term for almost anything built with AI. That misses an important distinction. There is a difference between asking an agent to produce something that looks right and using an agent to engineer something you can stand behind.

I use AI coding agents, and I expect their role in software development to keep growing. But I don't think writing less code makes someone less of an engineer. The real question is what happens to the engineering work around that code.

## Same tools, very different ways of working

In its literal sense, vibe coding is simple: describe what you want, let AI produce it, keep prompting until the result looks right, and don't spend much time reading or understanding the implementation. You judge success mainly by what you can see or try.

That is a perfectly reasonable way to explore an idea. A throwaway prototype, a quick internal tool, or a landing page mockup may not need much more. If you understand the risks and keep the scope small, the speed is the point.

**Agentic engineering starts with a different commitment: a human engineer remains responsible for the result.** The agent can inspect a repository, suggest a design, write the code, run tests, and even prepare a pull request. But someone still needs to decide whether the change is appropriate, whether the evidence is good enough, and whether it is safe to ship.

Both people might use the same model and write equally little code by hand. From the outside, their workflows can look identical. The difference is in what they know about the result and what they are prepared to take responsibility for.

A recent [AI as Normal Technology essay on software engineering](https://www.normaltech.ai/p/why-ai-hasnt-replaced-software-engineers) makes a useful distinction between deciding what to build, executing the work, and delivering it. Agents can make execution much faster. They don't remove the need to make sound decisions or own what gets delivered.

## The first engineering task happens before the first prompt

Imagine a client asks for bulk updates to application statuses in an admissions portal.

An agent can produce a convincing demo quickly: a table with checkboxes, a bulk-action button, an API endpoint, and a database update. It might even generate tests. The client can click the button, watch the statuses change, and conclude that the feature is done.

But what did *bulk update* actually mean?

Can a counsellor change applications assigned to another team? Which status changes are allowed? If 500 records are selected and 12 fail, do we roll back everything or report partial success? What happens if someone clicks twice, or if a network timeout causes the same request to be retried? Do we need an audit trail? Will this action trigger emails or other downstream events?

None of these are obscure implementation details. They define the feature.

I can ask an agent to enumerate edge cases and propose answers. In fact, I should. But it cannot decide the client's business rules on the client's behalf, and a confident answer is not the same as an agreed requirement. That still takes discussion, context, and judgment.

This is where good agentic engineering begins: with a clear problem, constraints, and acceptance criteria that exist independently of the generated code.

## A passing test is evidence, not a guarantee

Once the scope is clear, I want agents to do as much useful execution work as they can. Explore the codebase. Find the right integration points. Suggest a small change. Implement it. Add tests. Explain the tradeoffs.

Then comes the part that distinguishes assistance from abdication.

If the agent wrote both the code and the tests from a mistaken assumption, the tests may faithfully confirm the wrong behaviour. A green CI run cannot tell me whether we asked the right question.

The engineer needs to review the actual diff, not just the agent's summary. Do the permission checks exist at the right boundary? Does the database change work with the data we already have? Are errors handled in a way the user can understand? Did a simple feature quietly introduce a new dependency or change an unrelated workflow?

For the admissions example, I'd want to see tests for permissions, invalid transitions, duplicate requests, and partial failures. I'd also want to try the feature in a realistic environment and check the resulting data. If the action triggers emails or other side effects, I'd verify those too.

Agents are useful here as well. One agent can challenge another agent's implementation, generate adversarial cases, or help trace an unexpected result. But an agent reviewing an agent doesn't create an independent source of truth. The requirement and the observed behaviour still have to agree.

**The goal is not to prove that the AI followed the prompt. It is to prove that the change solves the right problem.**

## Production is where the distinction becomes expensive

At [Renderbit](https://www.renderbit.com/about-us/), we build and maintain software for clients. That means the work doesn't end when a feature looks good in a browser.

Someone has to think about database migrations, secrets, access control, deployment order, monitoring, backups, and rollback. Someone has to notice when a small change increases infrastructure costs or makes an older integration less reliable. Someone has to tell the client what changed and check that it still works after release.

An agent can help with all of those tasks. It can write the migration, prepare the deployment checklist, look for suspicious log entries, and suggest how to recover from a failure. Used well, that is a substantial gain.

What it cannot do is accept the responsibility on my team's behalf when production breaks at 2 AM.

This is also why unrestricted agent access is not an engineering strategy. A coding agent shouldn't get production credentials just because giving it full access makes a demo faster. It should have the permissions, context, and scope needed for the task, with approval for actions that carry real risk.

The more work I delegate, the more deliberate I need to be about the boundaries.

## How I want an agentic workflow to look

I don't think every change needs an elaborate process. I do think it needs an engineer who can answer five questions:

1. **What problem are we solving?** State the desired behaviour, the constraints, and what is explicitly out of scope before asking for an implementation.
2. **What can the agent safely do?** Give it relevant repository context, a bounded task, and access that matches the task. Ask it to state assumptions rather than invent requirements.
3. **How will we know it is correct?** Define acceptance criteria and useful tests before being persuaded by a polished demo. Review the diff and challenge the assumptions behind it.
4. **How will we ship and recover?** Check security, data changes, deployment steps, monitoring, and rollback in proportion to the risk.
5. **Who owns the result?** Make sure a human can explain the design choices, demonstrate the feature, respond to failures, and maintain it after the agent's session ends.

For a quick prototype, the answers can be short. For a payment flow, an admissions system, or a critical customer service, they need to be much more thorough. The principle stays the same.

## Stop counting code and start measuring outcomes

It's tempting to measure AI adoption by the percentage of code an agent wrote, the number of pull requests it opened, or how many hours of typing it saved.

Those numbers tell me something about how we produce code. They tell me very little about whether we're producing better software.

I'd rather know whether we can deliver a *verified* change sooner. Whether we find defects before users do. Whether the code is understandable to the next engineer. Whether deployments are uneventful, support requests fall, and the feature actually helps the people who asked for it.

There is a real risk that cheap code simply creates more code to review, debug, secure, and maintain. More output is useful only when it moves the project forward.

For a small team, this matters a lot. We can't afford to mistake a busy agent for a productive team.

## The skills that matter become more visible

None of this means engineers should cling to manual coding as a badge of honour. I don't care whether someone types every line of a migration or has an agent draft it. I care whether they understand what it will do to production data.

The skill that matters is being able to turn an unclear business request into a sound technical change, steer the implementation, spot mistakes, and own the result. Knowing the codebase, its history, the client's constraints, and the tradeoffs between possible solutions makes an engineer more effective with agents, not less relevant.

I've written about this before in [my post on ownership](/2026/07/08/on-ownership/): owning a task means owning the solution, not just the code. AI makes that distinction harder to ignore.

Vibe coding will continue to be useful. More people being able to build prototypes and small tools is a good thing. Some of those prototypes will grow into real products. When they do, the standard of work has to grow with them.

Agentic engineering isn't a rejection of AI-generated code. It's what happens when we take that capability seriously enough to apply engineering discipline to it.

The question isn't, "Did an AI write this?" It's, **"Can we explain why we built it this way, show that it works, and support it after it ships?"**
