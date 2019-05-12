# Itamae YETI

Automated installation of [YETI](https://github.com/yeti-platform/yeti) by using [itamae](https://github.com/itamae-kitchen/itamae).

## Prerequisite

Please install itamae beforehand.

```bash
gem install itamae
```

## Installation

This is an example of deploying YETI on Vagrant.

```bash
git clone https://github.com/ninoseki/itamae_yeti
cd itamae_yeti
vagrant up
itamae ssh --vagrant cookbooks/yeti/default.rb
```

After that, you can use yeti at `http://localhost:8080`.
