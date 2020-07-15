# markdown-journal-linter


Check if a markdown file matches requirements for instructions for authors

So far there are lua-filters for the following journals
- Diabetes Care
- Diabetologia


## Basic use

To use any of these filters, just add the filter to the YAML of your rmarkdown file

An example of this would be

```
---
title: "Example title"
abstract: >-
    Example abstract text
keywords: "keyword1,keyword2"
output:
    bookdown::pdf_book:
        base_format: rticles::elsevier_article
        keep_tex: true
        toc: false
        pandoc_args:
          - --lua-filter=check_markdown_authors_instructions.lua
---

```
