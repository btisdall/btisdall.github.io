---
title: Selecting on EC2 tags with jq
date: 2017-02-21
tags:
  - jq
  - AWS
---

In the [last jq article](../custom-jq-functions) I referred to the common operation of collapsing the `Reservations` and `Instances` arrays in the JSON returned by a `aws ec2 describe-instances` call to produce a stream of instance objects.

Given a stream of instance objects another extremely common operation is to filter it based on the key and value of one or more tags (note, it is possible to pre-filter the list using the `aws` command's `--filter tag:Key=foo,Values=bar` syntax but this is unsatisfactory as it requires re-fetching the data each time the filter is changed).

# Getting started

EC2 instance tags are represented in JSON under the key `Tags` by either nil if none are present or an array of objects. Let's assume we have a file `tags.json` with the following contents:


```json
{
  "Tags": [
    {
      "Key": "Role",
      "Value": "ApiServer"
    },
    {
      "Key": "Environment",
      "Value": "production"
    }
  ]
}
```

jq's versatile `contains` function can help us out here:

```
$ cat tags.json | jq '.Tags|contains([{"Key":"Role","Value":"ApiServer"}])'
true
```

```
$ cat tags.json | jq '.Tags|contains([{"Key":"Role","Value":"WebServer"}])'
false
```

This is pretty nice but data structures of the form ```[{"Key:" "foo", "Value": "bar"}]``` while ideal for data processing are not a natural way for humans to express information (very rarely do I find myself saying _'Hello my key "Name" has value "Ben"'_), plus it's hard work to type. Enter another jq filter `from_entries` (and its counterpart `to_entries`).


```
$ cat tags.json | jq '.Tags|from_entries' -cM
{"Role":"ApiServer","Environment":"production"}
```

Now we can transform the tags on the incoming objects and specify a match in a more compact and natural way:

```
$ cat tags.json | jq '.Tags|from_entries|contains({"Role": "ApiServer","Environment":"production"})'
true
```

This invocation has a small problem because it'll blow up if the value of `.Tags` is nil so we can give it a default value:

```
$ cat tags.json | jq '.Tags//[]|from_entries|contains({"Role": "ApiServer","Environment":"production"})'
true
```


Once we have a matching mechanism we can then use `select` to obtain the matching objects from our stream.

# Putting it all together

We can make use of the function we created in the [last jq article](../custom-jq-functions) to produce a stream of EC2 instance objects:

```
aws ec2 describe-instances | jq 'ec2i|select(.Tags//[]|from_entries|contains({"Role": "ApiServer","Environment":"production"}))|.InstanceId
```

Let's DRY things out further by storing our new filter in our `~/.jq` library file:

```
def ec2i: .Reservations[].Instances[];
def selec2tags(x): select(.Tags//[]|from_entries|contains(x));
```

Now we can do:


```
aws ec2 describe-instances | jq 'ec2i|selec2tags({"Role": "ApiServer","Environment":"production"})|.InstanceId'
```

But seeing as how it's very likely we're always going to chain these two filters we can call the first one in the second's definition:

```
def ec2i: .Reservations[].Instances[];
def selec2tags(x): ec2i|select(.Tags//[]|from_entries|contains(x));
```

Leaving us with:

```
aws ec2 describe-instances | jq 'selec2tags({"Role": "ApiServer","Environment":"production"})|.InstanceId'
```

