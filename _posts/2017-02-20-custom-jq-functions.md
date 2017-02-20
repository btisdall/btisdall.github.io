---
title: Custom jq functions
date: 2017-02-20
tags:
  - jq
  - AWS
---

[jq](https://stedolan.github.io/jq/) is a really useful tool but the documentation on modules and custom functions lacks concrete examples. I spend a large amount of time of working with AWS and when I do 99% of my jq invocations begin like this:


```
...|jq '.Reservations[].Instances[]|...'
```

I want to factor this filter out into a library so I can invoke it with less typing:

```
...|jq 'ec2i|...'
```

There are several ways do this:

# import RelativePathString as NAME

This takes a path relative to one of the include paths (here I'm setting a path with `-L`) and imports any function definitions into namespace `NAME`. Note the `.jq` extension should be omitted.

For example given a file `~/jqdefs/utils/ec2.jq` containing:

```
def ec2i: .Reservations[].Instances[];
```

I can do:

```
...|jq -L ~/jqdefs 'import "utils/ec2" as ec2utils; ec2utils::ec2i|...'
```

# include RelativePathString as NAME

Again takes a path relative to one of the include paths but this time simply imports any definitions into the top level namespace.

For example given the same library file as the previous example:

```
...|jq -L ~/jqdefs 'include "utils/ec2"; ec2i|...' 
```

# Including from ~/.jq

By default jq's module search path is 

```
["~/.jq", "$ORIGIN/../lib/jq", "$ORIGIN/../lib"]
```

where `$ORIGIN` is `$(dirname /path/to/jqbinary)`. However if `~/.jq` is a _file_ then any defintions contained therein will be automatically imported.

So now with `~/.jq` containing the same definition as before all we need is:

```
aws ec2 describe instances|jq 'ec2i|select(.State.Name|contains("running"))|.InstanceId' -r
```

Success!
