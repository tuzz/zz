## The tuzz automation tool

For automating all aspects of the 'tuzz' life experience.

### Overview

The purpose of this tool is to automate things that I'd otherwise do manually.

You're welcome to use anything here for your own ~~malevolent~~ purposes.
Whether that be the automation scripts or the architecture of the tool itself.
In particular, my Vim and iTerm setups are popular amongst colleagues.

### Setup

Run this:

```sh
curl -sL https://raw.githubusercontent.com/tuzz/zz/master/install | bash
```

The tool is designed to run with minimal dependencies on a fresh install of
macOS.

### Usage

Run `zz` to print help text for the command.

### Examples

```sh
$ zz provision --only homebrew,vim

$ zz provision --print iterm

$ zz provision --list

$ zz provision --edit dropbox

$ zz debug
```
