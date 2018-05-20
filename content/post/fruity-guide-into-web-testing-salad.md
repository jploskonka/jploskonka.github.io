---
title: Fruity guide into web testing salad
description: Comprehensive guide into web testing terminology, theory and technologies overview.
keywords: test automation, end to end testing, web testing, internet testing, test, quality assurance
date: 2018-05-24
---

Unit testing, end to end testing, integration testing, manual, automated, smoke,
monkey... That's quite a big list of levels and ways to test software. It's hard
to even list them all not even starting to get into details. Why is testing so
complex? Why there's so much ways to achieve so simple on first sight thing like
making sure your system works OK? In the end you just want to enter your website
and it expect it to work. What does it even mean that something works OK and
what it means it's broken? That's a lot of questions to answer and it's just a
tip of an iceberg.

Because of all those problems I decided to pick up a challenge and create a
simple to understand kinda guide through different ways to make sure your
application works as intended and meets expectations of your customers and
yourself so we can all live in a better world.

To make things more interesting and pleasant to think about I'm gonna use a
process of making a fruit salad as an example to describe what I'm talking
about and avoid tying things with specific technology. Mentioned practices
should be applicable to most of web-related technologies and be your starting
point when choosing best way on how to test your app. Because as with everything
related to creating software there's only one answer for **“How to test my new
unicorn-to-be project?”** question: **It depends**.

## Key points
Before I start telling you about all those berries and bananas let's start with
few key things to keep in mind during reading:

- Whenever I'm talking about fruits please keep in mind those are always
  everlasting fruits. Everlasting banana is such a such a banana that if you
  eat it, it's gonna magically grow again in exactly the same shape, taste and
  color as it was before.

- All code examples are written in pseudo-code kinda inspired by Ruby syntax but
  aren't real working code.

- I will publish one chapter more or less every week. Sign up to my newsletter
  if you want to get notified about new parts. No spam, I promise.

- I focus on testing techniques related to web applications, because that's what
  I have most experience with. However most of those can be applied to testing
  your GUI, mobile or refrigerator apps.

There're two ways of making any dish – you can just blindly cut all the fruits, put
them in a bowl, add some sugar and yogurt and serve to hungry people hoping
it's delicious. Of course there's hardly any chef in the world who would
approach cooking in this way. Standard procedure would be firstly to make sure
strawberries are tasty enough, sugar is sugar indeed and not some salt packed
inside sugar container and everything together tastes well.

Let's approach this as true developer would and make sure quality meets
five-star expectations from start to end.  It's kinda hard to automate tasting
of food but luckily you're developer and can codify your expectations. But why
would you do that?

## Benefits of tests automation
People make mistakes, it's one of very few things that are sure in our world. If
you give one strawberry, cut it into two pieces and give those pieces to two
people asking them if it's good strawberry one can say it's most delicious fruit
they ever had in their life while other one can say it's completely disgusting.
You'd also need to repeat this procedure again and again with every strawberry
you put in the bowl (remember, our strawberries are everlasting strawberries).

Same goes for code. If you present one website to one person he may use it in
different way than someone else and tell you it works perfectly well. Other one
may use it in different context and say it ain't working at all. When you
introduce any changes you need to go over testing procedure again and again and
again.

By automating your testing procedure you get:
- Easy to repeat (just run it again!) tests that always run in the same way.
- Quicker information about defects in your system – computers are way faster
  than humans in executing test scenarios.
- Earlier defects detection – by running tests more often and faster you get one
  more step of failures discovery before it reaches your end customer.
- Less money spend on bug fixing! :D

## Not everything can be automated
While talking about tests automation it's important to note that **not
everything can be automated**. There'll always be parts of your product you
need to subjectively taste and say if it's good or not according to your
personal feelings. Sometimes cost of automating things may be so high that it's
just better from economical point of view to just try things. However you need to
understand that manual tests are most expensive ones and should be
reduced to minimum.

Also when talking about code quality usually if writing tests for something is
really hard it may be a good sign that your code is in general badly designed.
It may be really hard to try banana if you put it inside closed plastic can with
drinking straw. You can still deliver it to customers and they still would be
able to taste it but it wouldn't be the most accessible banana ever. More on
this topic when we get to unit tests, but for now just keep in mind that code
hard to test is usually sign you should rethink what you're doing.

## Table of contents
- [coming soon] Are bananas and berries fresh and tasty? Unit testing
- [coming soon] Would unknown fruits fit into salad? Property testing
- [coming soon] Can I fit all those bananas into the bowl? Integration testing
- [coming soon] Is salad tasty? End to end testing
- [coming soon] Is masterchef happy with salad? Acceptance testing
- [coming soon] Would I feed my customers? Functional testing
- [coming soon] Can I add more fruits without breaking something? Regression testing
- [coming soon] What if I put chopsticks in this thing? Monkey testing
- [coming soon] Is it even edible? Smoke testing
- [coming soon] Can I deliver salad before client leaves? Performance testing
- [coming soon] What if there's million of customers wanting a salad? Load testing
- [coming soon] Is my kitchen thieve-proof? Security testing
- [coming soon] Do I have correct number of different tests? Bit about testing pyramid
- [coming soon] Can this salad get any better? Exploratory and manual testing
- [coming soon] Quality achieved, Bon appetit!
