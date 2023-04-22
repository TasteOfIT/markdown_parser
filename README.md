## Features

A flutter package that power by `markdown 7.0.0` to parse markdown syntax

## About markdown syntax

> Reference: [CommonMark](https://spec.commonmark.org/0.30/#characters-and-lines)
> Playground: [Online site](https://spec.commonmark.org/dingus/?text=)

### Blocks and inlines

Blocks:

- paragraphs
- block quotations
- lists
- headings
- rules
- code blocks
- ...

Inlines:

- text
- emphasized text
- links
- images
- code spans
- ...

A document contains a sequence of blocks—structural elements. Some blocks contain other blocks (
block quotes, list items). and other blocks contain inline content (headings, paragraphs).

### Leaf blocks

> Blocks that contains no other blocks
> `<br/>` for a line break
> `{M}`->Must, `{O}`->Optional, `{C}`->Conditional, `{N}`->Must not

| Name                       | Tags                  | Attrs       | Examples                                     | Notes                                                                              | Spaces before |
|----------------------------|-----------------------|-------------|----------------------------------------------|------------------------------------------------------------------------------------|---------------|
| Thematic breaks            | `hr`                  | -           | `***` OR `---` OR `___`                      | {M}3+ chars                                                                        | 0-3           |
| ATX headings               | `h1`, `h2`, ..., `h6` | -           | `# foo`, `## foo`, ... `###### foo`          | {M}space/tab after `#`s                                                            | 0-3           |
| Setext headings            | `h1` `h2`             | -           | ```Foo<br/>===``` OR ```Foo<br/>---```       | {C}blank line before                                                               | 0-3           |
| Indented code blocks       | `pre` AND `code`      | -           | ```    Foo<br/>    Bar```                    | {M}indent before chunks {C}blank line before                                       | 4+            |
| Fenced code blocks         | `pre` AND `code`      | class       | ```\`\`\`<br/>Foo<br/>Bar<br/>\`\`\`<br/>``` | {O}fenced with `~~~` {M}line break after opening fence {O}text after opening fence | 0-3           |
| HTML blocks                | ...                   | -           | ...                                          | ...                                                                                | 0-3           |
| Link reference definitions | `a`                   | href, title | `[foo]: /url "title"`                        | {O}spaces between could be tab or line breaks {O}`<>` for empty link               | 0-3           |
| Paragraphs                 | `p`                   | -           | ...                                          | {N}no blank lines                                                                  | 0-3           |
| Blank lines                | -                     | -           | ...                                          | {C}blank lines between blocks are ignored                                          | 0+            |

### Container blocks

> Blocks that contains other blocks
> `<br/>` for a line break
> `{M}`->Must, `{O}`->Optional, `{C}`->Conditional, `{N}`->Must not

| Name         | Tags         | Attrs | Examples                                                   | Notes                                                                             | Spaces before |
|--------------|--------------|-------|------------------------------------------------------------|-----------------------------------------------------------------------------------|---------------|
| Block quotes | `blockquote` | -     | `> foo` OR `># heading`                                    | {C}no space after `>` {C}no `>` for 2+ lines                                      | 0-3           |
| List items   | `li`         | -     | `- foo` OR `+ foo` OR `* foo` OR `1. foo` OR `2) foo`      | {M}1-9 digits for order list marker {M}correct indent line content {N}No negative | 0-3           |
| Lists        | `ol`, `ul`   | -     | ```- foo<br/>- bar<br/>``` OR ```1. Foo<br/>2. Bar<br/>``` | {M}same marker for same list {O} loose/tight due to blank lines                   | 0-3           |

### Inlines

> Inlines are parsed sequentially from the beginning of the character stream to the end.
> `<br/>` for a line break
> `{M}`->Must, `{O}`->Optional, `{C}`->Conditional, `{N}`->Must not

| Name                         | Tags             | Attrs           | Examples                                | Notes                                                                                       |
|------------------------------|------------------|-----------------|-----------------------------------------|---------------------------------------------------------------------------------------------|
| Code spans                   | `code`           | -               | `\`foo\`` OR `\`\`foo\`\``              | {O}lines are treated as space                                                               |
| Emphasis and strong emphasis | `strong` OR `em` | -               | `*foo*` OR `**foo**` OR `***foo* bar**` | {M}replace `*` with `_` {M}space/punctuation before&after {N}no spaces before&after content |
| Links                        | `a`              | href, title     | `[link](/uri "title")`                  | {M}space between uri and title {O}uri and title {O}no link breaks in uri                    |
| Images                       | `img`            | src, alt, title | `![foo](/url "title")`                  | {M}same as links                                                                            |
| Autolinks                    | `a`              | href            | `<http://foo.bar.baz>`                  | -                                                                                           |
| Raw HTML                     | -                | -               | `<a><bab><c2c>`                         | -                                                                                           |
| Hard line breaks             | `br`             | -               | -                                       | {O}2+ spaces and a line break {O}`\` and a line break {N}not inside blocks                  |
| Soft line breaks             | -                | -               | -                                       | {M}normal line breaks                                                                       |
| Textual content              | -                | -               | `foo bar`                               | {N}no markers inside                                                                        |
