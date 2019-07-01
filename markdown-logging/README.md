# markdown-logging.mk

## Example Uses
The following Makefile shows an example of three ways of logging markdown. The default theme used is a custom theme
called `uh`. Other themes can used by used by overriding the `MARKDOWN_THEME` variable
(i.e. `MARKDOWN_THEME = 799.3706`). Setting it to 'random' will choose a random theme.

```Makefile
include makefile-includes/markdown-logging/markdown-logging.mk

# Required for the define version
.ONESHELL:
test-markdown-logging:
  $(call logmd,"# Example: Standard Use")

  $(call logmd," \
		\n# Example: Inline Multiline \
		\nThis is a paragraph. The newlines are there because \`Make\` collapses whitespace to a single space which \
		\ninterferes with the markdown. Too bad because it makes it less readable.\
		\n
		\n**Note:**
		\n- You can't use a comma in this format without defining it as a varaible. \
		\n- You have to be careful of whitespace and newlines.")

    $(call logmd,"$(defined-markdown)")

define defined-markdown
# Example: Define Multiline
**Note:** There are some quirks.

  * Backticks have to be escaped.

  * Sometimes you need to add extra newlines (like with lists) since *Make* will trim whitespace.

  * The indent with four spaces doesn't work.

  * Double newlines won't create a new paragraph.  You can force it by adding an html line-break.

## Taken from *https://guides.github.com/features/mastering-markdown/*

There are many different ways to style code with GitHub's markdown. If you have inline code blocks, wrap them in backticks: \`var example = true\`.<br/>

GitHub also supports something called code fencing, which allows for multiple lines without indentation:

\`\`\`
if (isAwesome){
  return true
}
\`\`\`

And if you'd like to use syntax highlighting, include the language:

\`\`\`javascript
if (isAwesome){
  return true
}
\`\`\`
endef
```

## Developer info
The binary files were created here with this project:
https://github.com/UniversityOfHawaii/terminal-markdown-viewer

The base python project is here:
https://github.com/axiros/terminal_markdown_viewer

### Themes
Themes are defined in `bin/ansi_tables.json`. Adding your own is a little tricky because it's hard to know what
value is assigned to what color.  I made a spreadsheet to give me a command to map them all.

In the first column I had:

```
="""" & ROW(A1) & """: {""name"": ""uh"",""ct"": [""" & ROW(A1) & """, """ & ROW(A1) & """, """ & ROW(A1) & """, """ & ROW(A1) & """, """ & ROW(A1) & """]},"
```

In the second column I had:
```
="MARKDOWN_THEME=""" & ROW(B1) & """ make -s test-markdown"
```

Then I copied them down the sheet about 256 rows.
Next, copy the first column to the `ansi_tables.json file`.

Then, a Mafile that looks like the following:

```Makefile
include makefile-includes/markdown-logging/markdown-logging.mk
test-markdown:
  $(call logmd,"# This is color value $(MARKDOWN_THEME)")
```

Last, copy column two and run it in the console.
