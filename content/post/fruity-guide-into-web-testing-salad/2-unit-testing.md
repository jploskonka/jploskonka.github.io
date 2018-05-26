---
title: Unit testing
date: 2018-05-26
---

Hello! In this chapter we're gonna talk a bit about unit testing. Let's start
preparing our salad. First thing we need to have are fruits. We're gonna do
super fresh, healthy and extremely tasty (bad salad, ever) mix of bananas and
strawberries in first step, we have no idea what're gonna be next ingredient,
when is it gonna be added or if we even really want bananas or straweberries.
We're building a tech-salad here anyway, we need to be agile (or have no idea what
the hell we're doing).

[change this to 1 fruit and knife maybe?]

So we have bananas and straweberries ready to be cut on the cutting-desk [?is
such word in english?]. There's also a knife and a bowl. So let's do our salad!

[!! no knife in the end, already cut !!]

``` ruby
class Banana
  def initialize(yellowness = 0)
    @yellowness = yellowness
  end

  attr_reader :yellowness

  def good?
    @yellowness >= 4
  end
end

class Strawberry
  def initialize(sweetness = 2)
    @sweetness = sweetness
  end

  attr_reader :sweetness

  def good?
    @sweetness >= 2
  end
end
```

and specs:

``` ruby
describe Banana do
  it 'is good with yellowness at least 4' do
    banana = Banana.new(4)

    expect(banana.good?).to eq(true)
  end

  it 'is bad with yelowness 3 or less' do
    banana = Banana.new(3)

    expect(banana.good?).to eq(false)
  end
end
```

``` ruby
describe Strawberry do
  it 'is good with sweetness at least 3' do
    strawberry = Strawberry.new(3)

    expect(strawberry.good?).to eq(true)
  end

  it 'is bad with sweetness less than 3' do
    strawberry = Strawberry.new(2)

    expect(strawberry.good?).to eq(false)
  end
end
```

## Mocking
``` ruby

```

That's it! Unit testing in a nutshell. Few important things here to note:

- Look how unrelated are bananas and strawberries here. Both classes has no idea
  about existence of another one. The same goes for tests - there's no mention
  of strawberries in bananas tests nor bananas in strawberries tests. You can
  easily modify one test without interfering with another. Also implementation
  change of any of those object won't affect test results of another.
- Those tests are super fast. On my machine it takes [?...add benchmark ?]
- Note how detailed our tests are. Each example specifies exact value to
  describe specific fruit attributes and than checks this particular fruit. If
  we want to test different values we would need to add specific examples for
  that. What about max and minimal values of yellowness and sweetness? Is there
  banana with inifnite yellowness? Or strawberry so sweet you die when you eat
  it? It's a lot of cases to cover.


## Summary
### Pros of unit tests
- Super fast! You can test your code against thousands of expectations in
  seconds.
- Good place to cover known edge cases that happen rarely but cause bugs (like what
  would happen if I call this method without parameters? Or array instead of
  hash?).
- Because of their verbosity unit tests are good place to learn about specific
  parts ofyour code.  When writen well can be easily used to automatically
  generate documentation for classes and methods.


### 
- 

