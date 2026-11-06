# richorama.github.io

[![Gitter](https://badges.gitter.im/richorama-chat/Lobby.svg)](https://gitter.im/richorama-chat/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Install the GitHub Pages dependencies and build the site with:

```shell
bundle install
bundle exec jekyll build
```

## Agent-readable content

After adding or editing a post, regenerate the Markdown copies and agent indexes:

```shell
ruby scripts/generate-agent-content.rb
```

Check that committed agent content is current with:

```shell
ruby scripts/generate-agent-content.rb --check
```