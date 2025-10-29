---
layout: post
title: Microsoft Copilot Researcher Solves Today's Wordle Using "Computing Using Agent"
date: 2025-10-27 09:00:00
summary: I watched Microsoft Copilot Researcher tackle today's Wordle puzzle using its "Computing Using Agent" feature. Here's how AI approaches word puzzles with systematic reasoning and computational strategy.
---

Today I decided to test Microsoft Copilot Researcher's problem-solving capabilities by asking it to solve today's Wordle puzzle. What I discovered was fascinating - the AI didn't just guess randomly, but used a systematic approach through its "Computing Using Agent" feature.

## The Prompt

> "do today's new york times wordle"

## The Approach

The Computer Using Agent has access to a desktop browser. It directly opened the page, waited for it to load, and then paused to confirm what it should do with the cookie banner.

![Initial Wordle screen](/images/wordle1.png)

## The Strategic Process

The AI then started entering letters and tried some words out. It quickly devised a strategy to place "yellow" letters in different positions, systematically exploring the solution space.

When the constraints became complex, the AI wrote a Python program to filter a word list based on all the discovered constraints:


```python
import os, re
words=[]
words_path='/usr/share/dict/words'
try:
    with open(words_path) as f:
        for line in f:
            word=line.strip().lower()
            if len(word)==5 and word.isalpha():
                words.append(word)
except:
    pass
banned=set(list('arsxlqpu'))
res=[]
for w in words:
    if any(c in banned for c in w):
        continue
    if 'e' not in w or 'i' not in w:
        continue
    if w[3]!='i':
        continue
    if any(pos in ['i'] for pos in w[:3]):
        if 'i' in w[:3]:
            continue
    # Apply position constraints for E and I based on Wordle feedback
    if len(w)<5: continue
    if w[3]=='e' or w[4]=='e':
        continue
    # E must be at index 1 or 2 based on yellow feedback positions
    if w[0]=='e' or w[4]=='e' or w[3]=='e':
        continue
    if w[1]!='e' and w[2]!='e':
        continue
    res.append(w)
print(res[:200], 'count', len(res))
```

This code systematically filtered the word list by:
- Excluding letters confirmed as not in the word (A, R, S, X, L, Q, P, U)
- Requiring both E and I to be present
- Enforcing position constraints based on yellow/green feedback
- Narrowing down to valid candidate words

After a few more tries, using the filtered list, the AI successfully solved the puzzle:

![Wordle solved](/images/wordle2.png)

## The Outcome

> I successfully completed today's Wordle on the New York Times website. Starting with "ARISE," I iteratively refined my guesses (PIXEL → EQUIP → DEBIT → FETID). The correct solution was FETID, which I found on my fifth attempt.

The solving sequence demonstrates the AI's methodical approach: **ARISE → PIXEL → EQUIP → DEBIT → FETID**

## Conclusion

Watching Microsoft Copilot Researcher solve today's Wordle was a fascinating glimpse into how AI can combine multiple capabilities to tackle problems systematically. What struck me most was how the AI seamlessly switched between different tools and approaches:

- **Browser automation** to directly interact with the web interface
- **Strategic thinking** to develop an optimal word selection approach  
- **Programming** to filter word lists based on constraints
- **Logical reasoning** to apply Wordle feedback rules systematically

The AI didn't just brute-force the solution - it demonstrated genuine problem-solving skills. It understood the game mechanics, developed a strategy, wrote code to implement that strategy, and iteratively refined its approach based on feedback.

Perhaps most impressively, the entire process was transparent. I could follow the AI's reasoning at each step, from the initial word choice to the Python code logic. This transparency makes the "Computing Using Agent" feature not just powerful, but trustworthy.

While solving Wordle might seem like a simple task, the underlying capabilities demonstrated here - systematic reasoning, tool switching, code generation, and constraint satisfaction - have much broader applications in research, analysis, and problem-solving across many domains.

The future of AI assistants isn't just about answering questions or generating text - it's about agents that can actively engage with digital environments, write code to solve problems, and explain their reasoning every step of the way. Today's Wordle solution was just a small example of what's possible when AI can truly "use a computer" rather than just process text.
