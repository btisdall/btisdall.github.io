---
title: Pulling Puppet's strings with Capistrano
date: 2012-01-27 14:17:51
categories: Capistrano, Puppet, Ruby, DevOps, deployment
---

Last year we took our first serious step into the world of system automation at work when we [Puppetised]("http://puppetlabs.com/") our web infrastructure. Puppet is awesome, but we soon realised:

*Configuration management and deployment are not the same thing.*

In a typical CFMS deployment the client executes autonomously, bringing the system configuration back into line where necessary whereas for deployment *timing is of the essence.* We wanted to run Puppet only on demand, whether to normalise configurations or deploy our application debs (yes, we were aware of MCollective but we were too busy to get started with it at that particular time).

So our first effort was quite literally:

```bash
for i in 10.1.1.{1..20}; do
  echo "Deploying to $i"
  ssh $i sudo puppetd --test
done
```

This works fine, but is error-prone (somewhat negating the point of a config mgmt system!) and *serial* (slow!). We could start packaging this up in a script and doing something to parallelise it but wouldn't it be nice if someone had solved the problem already? Enter [Capistrano]("https://github.com/capistrano/capistrano/wiki/Documentation-v2.x"):

# If the Cap fits...

* Originally written by Jamis Buck of 37Signals.
* Written in Ruby (surprise!).
* Been around for yonks, stable.
* DSL for remote task automation.
* If you have a Rails app it does all manner of deploy magic out of the box.
* Still super useful as a general purpose remote execution tool if not.
* Define tasks and the servers on which they should be executed in simple declarative style.
* Bolt on functionality by using lower level parts of the API.
* Docs could use some love!

# A very simple task

## The code
Place this in a file named "capfile" (the default recipe file if none is specified with `-f FILE`)

```ruby
    desc "This is a test task."
    task :test_me, :hosts => [ "localhost" ] do
        run "uptime"
    end
```

## Printing a task's documentation

In Capistrano speak this is *explaining*:

```ruby
    bentis@tork:~$ cap -e test_me
    ------------------------------------------------------------
    cap test_me
    ------------------------------------------------------------
    This is a test task.
```

## Executing a task

```ruby
    bentis@tork:~$ cap test_me
    * executing `test_me'
    * executing "uptime"
    servers: ["127.0.0.1"]
    [127.0.0.1] executing command
    ** [out :: 127.0.0.1] 18:29  up 2 days, 14 mins, 5 users, load averages: 3.05 2.38 1.60
    command finished in 89ms
```

## List available tasks

Also prints the first line of each desc if it exists:

```ruby
    bentis@tork:~$ cap -T
    cap invoke  # Invoke a single command on the remote servers.
    cap shell   # Begin an interactive Capistrano session.
    cap test_me # This is a test task
    
    Extended help may be available for these tasks.
    Type `cap -e taskname' to view it.
```

# Hosts & Roles

You probably want to run your tasks on predefined sets of hosts - the usual way to do this is with *roles*.

## Defining Roles

You can define a role in one go like this:

```ruby
    role :frontend, "web1.example.com", "web2.example.com", "web3.example.com", "web4.example.com"
```

But *role* appends, so it's easier to manage them like this:

```ruby
    role :frontend, "web1.example.com"
    role :frontend, "web2.example.com"
    role :frontend, "web3.example.com"
    role :frontend, "web4.example.com"
    role :frontend, "web5.example.com"
    role :frontend, "web6.example.com"
```

## Adding attributes to roles

```ruby
    role :frontend, "web1.example.com", :cluster_a => true
    role :frontend, "web2.example.com", :cluster_a => true
    role :frontend, "web3.example.com", :cluster_a => true
    role :frontend, "web4.example.com", :cluster_b => true
    role :frontend, "web5.example.com", :cluster_b => true
    role :frontend, "web6.example.com", :cluster_b => true
```


## Using Roles in a task

```ruby
    desc "This is a test task"
    task :test_me, :roles => "frontend" do
        run "uptime"
    end
```

## Using Roles plus attributes

```ruby
    desc "This is a test task"
    task :test_me, :roles => "frontend", :only => { :cluster_a => "true" } do
        run "uptime"
    end
```

## Using hosts from an external source
If hosts or roles appear as part of the "task" statement they will be evaluated when the recipe file is loaded, almost certainly not what you want if you're obtaining them dynamically. Place with the "run" statement instead:

```ruby
    desc "This is a test task"
    task :test_me do
        run "uptime", :hosts => something_that_returns_an_array()
    end
```

# Code re-use

Re-using code is easy, to include the contents of `myfile.rb` just put `load "myfile"` in your recipe. If you're using another file suffix you must be explicit and say `load myfile.cf` for example.

# Extending recipes

## Option handling

Options are passed via the `-s` & `-S` switches (the former sets the variable *after* the recipe file has loaded, the latter *before*).

```ruby
    desc "Demo option passing"
    task :test_me do
        logger.info "#{myopt}"
    end
```

Invoke thusly:

```ruby
    bentis@tork:~$ cap test_me -s myopt=foo
     * executing `test_me'
    ** foo
```

Note we used the API's `logger` method to do the print.

## Enumerating hosts from roles

`task` and `run` can use roles directly, but what if we the user want to see the resolved list of hosts before running some potentially destructive action? This is what the `find_servers` method is for.

```ruby
    servers_array = find_servers :roles => :frontend, :only => { :cluster_a => true }
    logger.info "Found these servers:"
    servers_array.each do |s|
        logger.info "#{s}"
    end
```

## Interactivity

You can use plain old Ruby to read STDIN and process the reply, but Capistrano has a convenience method to help out:

```ruby
        set(:reply) do
            Capistrano::CLI.ui.ask " ** Proceed? (y/N): "
        end
        # do something with :reply
```

# Putting it all together

## Server config file

```
role :frontend, "web1.example.com", :cluster_a => true
role :frontend, "web2.example.com", :cluster_a => true
role :frontend, "web3.example.com", :cluster_a => true
role :frontend, "web4.example.com", :cluster_b => true
role :frontend, "web5.example.com", :cluster_b => true
role :frontend, "web6.example.com", :cluster_b => true
```

To test this on your local machine put this in your */etc/hosts*:

```ruby
    127.0.0.1 web1.example.com web2.example.com web3.example.com web4.example.com web5.example.com web6.example.com
```

## Puppet deploy script

```ruby
load "servers" # this file contains our role definitions

def run_on_nodes(cmd)

    # Use a default role
    unless exists?(:servers)
        set :servers, "dev"
    end

    # invoke find_servers() appropriately depending on whether the 'restrict' opt was passed.
    # I'm sure there's a better way...
    if exists?(:restrict)
        servers_selected = find_servers :roles => "#{servers}", :only => { :"#{restrict}" => true }
    else
        servers_selected = find_servers :roles => "#{servers}"
    end

    if servers_selected.length == 0
        logger.info "No servers matched, quitting..."
        exit
    end

    logger.info %Q{About to run "#{cmd}" on servers:}
    servers_selected.each do |s|
        logger.info "#{s}"
    end

    set(:reply) do
        Capistrano::CLI.ui.ask " ** Proceed? (y/N): "
    end
    reply.downcase == "y" || exit

    run "#{cmd}", :hosts => servers_selected
end

task pdeploy do
    run_on_nodes("sudo puppetd --test --noop")
end

task get_uptime do
    run_on_nodes("uptime")
end
```

Ok so we're wrappering `run` here. We accept a role and optionally a attribute from the command line. Assuming these resolve to a non-empty list of hosts display them back to the user, allowing them to continue or quit. If we continue we can pass the list of hosts directly to run rather than repeating ourselves with roles and we're done.

## Off we go!

```ruby
    bentis@tork:~$ cap pdeploy -s servers=frontend -s restrict=cluster_b
      * executing `pdeploy'
     ** About to run "sudo puppetd --test" on servers:
     ** web4.example.com
     ** web5.example.com
     ** web6.example.com
     ** Proceed? (y/N): y
      * executing "sudo puppetd --test"
        servers: ["web4.example.com", "web5.example.com", "web6.example.com"]
        [web4.example.com] executing command
        [web5.example.com] executing command
        [web6.example.com] executing command
     ** [out :: web5.example.com] (output omitted)
     ** [out :: web6.example.com] (output omitted)
     ** [out :: web4.example.com] (output omitted)
        command finished in 12470ms
```

# Where next

Hopefully we'll get round to trying *MCollective*, when we do I'll post our experiences back here. Oh yes and before I forget, comments on my dodgy Ruby are welcome, nay, encouraged!
