# GPTCLI

This library provides a UNIX-ey interface to OpenAI.
It is a fork of [openai_pipe](https://github.com/Aesthetikx/openai_pipe), created by [Aesthetikx](https://github.com/Aesthetikx/openai_pipe), kudos to him for his awesome work!  
The goal of this fork was to add the ability to choose which OpenAI model to use, as well as adding context prompts support. Thanks to these new features, you can have your own highly specialized GPT4 personal assistant, directly in your terminal! Productivity stonks 📈📈📈   

See [Installation](#installation) and [Setup](#setup) below, but first, some examples.

## Examples

```console
$ gpt what is two plus two
Two plus two is equal to four.
```

```console
$ uptime | gpt convert this to json
{
        "time_of_measurement": "13:48:26",
        "up_time": "30 days, 18:07",
        "users": 3,
        "load_average": [
                0.46,
                0.61,
                0.79
        ]
}
```

```console
$ gpt -c you are Vitalik Buterin, the creator of Ethereum. You know very well the whole EVM ecosystem and how to write perfectly optimized Solidity smart contracts -p Write a simple ERC20 token smart contract using OpenZeppelin library, respond only by the smart contract, do no write explanations > erc20.sol
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply);
    }
}
```

Setting default context to `fullstack`:
```console
$ gpt "what is your role?"
As your personal assistant, my role is to assist you in various tasks and answer your questions related to my areas of expertise, which include UNIX systems, bash, Python, Django, SQL, Javascript, ReactJS, and NextJS. I can help you with programming and development, server administration, debugging your code or scripts, optimizing performance, code review, providing recommendations for best practices, and more.

```

```console
$ gpt list the nine planets as JSON | gpt convert this to XML but in French | tee planets.fr.xml
<Planètes>
   <Planète>Mercure</Planète>
   <Planète>Vénus</Planète>
   <Planète>La Terre</Planète>
   <Planète>Mars</Planète>
   <Planète>Jupiter</Planète>
   <Planète>Saturne</Planète>
   <Planète>Uranus</Planète>
   <Planète>Neptune</Planète>
   <Planète>Pluton</Planète>
</Planètes>
```

```console
$ curl -sL "https://en.wikipedia.org/wiki/cats" | head -n 5 | gpt extract just the title of this webpage | figlet
  ____      _            __        ___ _    _                _ _
 / ___|__ _| |_          \ \      / (_) | _(_)_ __   ___  __| (_) __ _
| |   / _` | __|  _____   \ \ /\ / /| | |/ / | '_ \ / _ \/ _` | |/ _` |
| |__| (_| | |_  |_____|   \ V  V / | |   <| | |_) |  __/ (_| | | (_| |
 \____\__,_|\__|            \_/\_/  |_|_|\_\_| .__/ \___|\__,_|_|\__,_|
                                             |_|
```

```console
$ ls | gpt What is this directory for?
This directory contains the source code for a Ruby-based project called gpt-cli. It includes files related to the project's license (LICENSE.txt), changelog (CHANGELOG.md), dependencies (Gemfile and Gemfile.lock), executables (bin and exe), libraries (lib), signature (sig) and tests (spec). There is also a Rakefile and a README.md file which provide information about how to build and install the project, as well as its features and usage. Finally, it includes the gpt-cli-0.1.0.gem and gpt-cli.gemspec files which are used to build the gem which can be installed on other systems.
```

```console
$ ls -l | gpt which of these are directories?
bin, exe, lib, sig, spec
```

```console
$ ls | gpt "For each of these files, provide a description of what is likely to be their contents?"
bin - Likely contains compiled binary executable files.
CHANGELOG.md - Likely contains a log of changes/modifications, such as bug fixes and new features, that have been made to the project.
exe - Likely contains executable files.
french_planets.xml - Likely contains an XML file containing data related to planets, likely in French.
Gemfile - Likely contains Ruby code for the project's dependencies.
Gemfile.lock - Likely contains a snapshot of the dependencies of the project and versions of those dependencies.
lib - Likely contains the Ruby source code (e.g. classes and modules) for the project.
LICENSE.txt - Likely contains the terms of use/license for the project.
gpt-cli-0.1.0.gem - Likely contains a gem that gathers information from the OpenAI API.
gpt-cli.gemspec - Likely contains configuration details for the gem.
planets.lst - Likely contains a list of planets.
poem.txt - Likely contains a text file containing a poem.
Rakefile - Likely contains Ruby tasks and dependencies that can be used in projects.
README.md - Likely contains general information about the project and usage instructions.
reverse.lst - Likely contains a list of words or items that are in reverse order.
sig - Likely contains digital signatures to validate individual files.
spec - Likely contains Ruby specs (i.e. tests) for the project.
uptime.json - Likely contains a file with information regarding system uptime of a computer.
```

```console
$ git commit -m "$(git status | gpt write me a commit message for these changes)"
[master 7d0271f] Add new files and modify README.md
```

```console
$ git status | tee /dev/tty | gpt write me a sonnet about the status of this git repository
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        gpt-cli-0.1.0.gem

nothing added to commit but untracked files present (use "git add" to track)

My master branch may lack to thee its kin
For change it holds the only force within
Thé untracked files, they still remain unnamed
‘Tis fervent hope thé change will soon be claimed

Fraught with the choice to leave or to persist
The repository wavers ‘tween future and past
The gpt-cli-0.1.0 gem stands out
Waiting to be added, not yet about

The commit awaits for brave new changes bold
While time’s old force is ever unfurled
Commit forth young mind, furrow not to crawl
From untracked files, a future stands tall.
```

```console
% history | gpt what was the last thing I did
The last command you entered was 'history'.
```
n.b. somehow it sees history-esque output and determines that history was typed -- the history command does not itself include the history command in the output.

```console
$ history | gpt what was the last thing I did before typing history
The last thing you did was amend a README.md file.
```
n.b. here it determines the amend was for README.md not from the previous command but from ones prior that edited README.md.

```console
$ cat lib/gpt-cli/version.rb | gpt rewrite this file with just the minor version incremented | sponge > lib/gpt-cli/version.rb
$ git diff
diff --git a/lib/gpt-cli/version.rb b/lib/gpt-cli/version.rb
index 0f82357..cc57fab 100644
--- a/lib/gpt-cli/version.rb
+++ b/lib/gpt-cli/version.rb
@@ -1,5 +1,5 @@
 # frozen_string_literal: true

 module GPTCLI
-  VERSION = "0.1.0"
+  VERSION = "0.1.1"
 end
```

```console
$ ruby -e "$(gpt write me a python script that prints the current month | gpt translate this into ruby)" | gpt translate this into French
Le mois courant est Décembre.
```

## Installation

Install the gem by executing:

    $ gem install gpt-cli

## Setup

This library uses [quick_openai](https://github.com/Aesthetikx/quick_openai) which itself uses [ruby-openai](https://github.com/alexrudall/ruby-openai), so you may want to familiarise yourself with those projects first.

This library uses OpenAI GPT3 to generate responses, so you will need to have your access token available in ENV. In .bashrc or equivalent,
```bash
export OPENAI_ACCESS_TOKEN=mytoken
```
Set the model you want to use in ENV:
```bash
export OPENAI_MODEL="gpt-3.5-turbo"
```
(Optional) set the default context prompt you want to use (for now, there's only 3 basic prompts available `python`, `fullstack` and `blockchain` in `lib/contexts.rb`):
```bash
export OPENAI_DEFAULT_CONTEXT="python"
```
By default the executable is called `gpt-cli`. It is reccommended to alias this command to something shorter in .bashrc or equivalent, e.g.
```bash
alias gpt="gpt-cli"
```

## Usage

There's two optional parameters you can set when running `gpt`:  
`gpt -c <custom_context_prompt> -p <your prompt>`  
`--context -c`: this will be the context prompt, see basic contexts in `lib/contexts.rb`. You can put a key ofrom the contexts hash of `lib/contexts.rb` or a custom context.  
`--prompt -p`: your actual prompt.  
You can also run gpt without any arguments, just your question. In this case, the context prompt will default to the one defined by ENV var `OPENAI_DEFAULT_CONTEXT` if it exists. If not, no context will be added.  
See examples above for an overview of some usecases. Possibilities are endless.

## Notes

Be aware that there is a cost associated every time GPT3 is invoked, so be mindful of your account usage. Also be wary of sending sensitive data to OpenAI, and also wary of arbitrarily executing scripts or programs that GPT3 generates.
Also, this is my very first time working in Ruby. So please be indulgent 🙏  
A future release will  by a JSON file so user will be able to easily add/modify custom context prompts.

## TODO

- Replace `lib/contexts.rb` by a JSON file that will be located wherever user wants, fetch it's path through ENV var. This way we can easily add/modify custom context prompts.  
- Add dall-e support  
- Add proper documentation  

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/FlorianMgs/gpt-cli.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
