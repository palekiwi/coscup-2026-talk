---
date: 2026-08-04
audience-count: 1
---

## Recorded durations

```
Intro (2): 13:12-16 (4 min)
Why this talk (3): 13:16-20 (4 min)
Security (4): 13:20-26 (6 min)
Environments (5): 13:26-28 (2 min)
Sandbox (6): 13:28-30 (2 min)
Containers (7): 13:30-31 (1 min)
README (8): 13:31-33 (2 min)
Example 1 (9): 13:33-37 (4 min)
Flake (10): 13:37-38 (1 min)
Nix lang (11): 13:38-42 (4 min)
Minimal Nix (12): 13:42-51 (9 min)
Nix boundary (13): 13:51-53 (2 min)
Community flakes (14): 13:53-57 (4 min)
Config from local (15): 13:57-00 (3 min)
Wrapped Ruby (16): 14:00-03 (3 min)
Prod flake (17): 14:03-04 (1 min)
Example 2 (18): 14:04-07 (3 min)
Vertical comp (19): 14:07-08 (1 min)
Distro to repos (20): 14:08-09 (1 min)
Isolation (21): 14:09-10 (1 min)
Learning curve (22): 14:10-11 (1 min)
Starting (23): 14:11-12 (1 min)
End (24):	14:12-13 (1 min)
```

## General impressions

The listener praised the value of the talk highly although the talk ended up
running over-time by a lot: almost a 1hr mark on the nose.

### Listener feedback

1. The listener found the slide about the README as a promise that nobody enforces
   (until you use Nix) where it hit home for him as he has seen this kind of
   READMEs countless times in his career and typically faced issues.

2. The other slide that was illuminating was the "vertical composition" of
   devshells - the listner found it a very valuable pattern.

3. The slide about "pragmatic"/"hermetic" appoaches didn't add anything and was
   a bit confusing - the listner suggested dropping it.

### Speaker impressions

1. I enjoyed giving most of the talk, I think the structure is good but some
   slides in the first part (before we reach the technical part about flakes)
   could be reordered to build and keep up momentum better.

2. I have identified an opportunity to engage the audinece and make it more
   interactive midway: when explaining the basic syntax of Nix (functions,
   attribute sets), I announce that the audience must focus because there will be a
   quizz on the next slide (the minimal flake). The quizz consists of pointing at
   different "elements" of the minimal flake and asking the audience to identify
   the type:

- curly braces wrapping the entire flake content? that's an attribute set!
- inputs and outputs? these are attributes!
- the type of `outputs`? A hard one, but this is a function!
- can you spot a relationship between the shape of `inputs` and `outputs`?
  Yes, that's pattern matching - outputs expect to be called with the inputs!

3. We need a new slide, probably right after "About Me", that shows a simple
   table of contents/agenda. We need to enumerate the sections, e.g.:

- "Why this? Why now?"
- "The problem you may not realize that you have"
- "The promise Nix keeps for you"
- "Case Study 1: Nix Deep Dive for Rubyists"
- "Case Study 2: Doing OpenSource with Nix"
- "Next steps: Get started today"

4. We need to cut.

- First and obvious candidate: "pragmatic"/"hermitic" duality. This was hard to
  explain, too complex, too much content, the most nuanced part of Nix for
  rubyists, simply no space in this talk for such level of detail. Just cut
  straight to the "expanded flake"

- Second candidate: security and sandboxing/isolation. Takes too much time to go
  through, adds nothing important. Use other slides to introduce the sandbox, no
  need for a separate intro/breakdown slide.

- Shopify anecdote (info on slides can stay, some people need something to read)
  but I won't talk about Shopify at length: just say Shopify is going hard right
  now and this is Ruby news and I talked to them at Kaigi.

- Minimal nix somehow took a lot of time but that's because of the quizz which I
  belive is a very high value to have. Just be mindful to keep it quick.
